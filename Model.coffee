{ reqdir } = require "./helper"
{ createHash } = require 'crypto'

client = null

model = null
define = (name) ->
  model = (subs...) -> "#{name}s" + if subs?
                                   ":#{subs.join ":"}"
                                 else
                                   ""
mixin = (to, from) ->
  for key, value of from
    to[key] = value

hash = (id) ->
  shasum = createHash 'sha1'
  shasum.update id
  shasum.digest('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/\=+$/, '')

class ValidationError extends Error
  constructor:(@unmet_reqs) ->

class Model
  @define: define
  @Map =
    checked: (val) -> val == 'on'
    number: (val) -> Number(val)
    boolean: (should_be) -> (val) -> should_be == val

  @ValidationError = ValidationError
  constructor: (@name, params={})->
    @key = define @name
    @allowed 'id'
    @set params

  mapping: (@maps) ->

  map: () ->
    for key, mapper of @maps
      @params[key] = mapper @params[key]
    @

  set: (params) ->
    @params = @params ? {}
    for param, allowance of @definitions
      value = params[param]
      value = null if value is ""
      value = Number(value) unless not value? or isNaN Number value
      value = true if value == "true"
      value = false if value == "false"
      @params[param] = value
    @

  validate: (params=@params) ->
    validation_errors = []
    for param, allowance of @definitions
      if allowance != "allow"
        if 'function' is typeof allowance
          if not allowance @params[param]
            validation_errors.push param
        else if not params[param]? or params[param] is ""
          validation_errors.push param
    if validation_errors.length
      throw new ValidationError validation_errors
    @

  index: (@indexes) ->

  allowed: (params...) ->
    @definitions = @definitions ? {}
    for param in params
      @definitions[param] = 'allow'

  required: (with_validators, params...) ->
    if 'string' is typeof with_validators
      params.unshift with_validators
      with_validators = null

    @definitions = @definitions ? {}
    if with_validators?
      for key, val of with_validators
        @definitions[key] = val
    for param in params
      @definitions[param] = 'require'

  defineModels:(models, _client) ->
    Model.client = _client
    client = _client
    @models = models
    Model.models = models

    for key, definition of models
      @models[key] = definition key, Model if definition != Model
      model = define key
      def = @models[key]
      do (def, model) ->
        mixin def,
          all: (cb) ->
            client.zrange model('index'), 0, -1, (err, ids) ->
              if ids?
                multi = client.multi()
                for id in ids
                  multi.hgetall model(id)
                multi.exec (err, replies) ->
                  cb replies
              else
                cb []

          searchById: (id, cb) ->
            @get hash(id), cb

          get: (id, cb) ->
            client.hgetall model(id), (err, model_params) ->
              cb err, new def (model_params)

          ValidationError: ValidationError


  destroy: () ->
    client.del @key(@params.id)
    client.zrem @key('index'), @params.id

  @hash: hash

  updateId: (id) ->
    sha_id = hash id.toString()
    if sha_id isnt @params.id
      @destroy()
      @params.id = sha_id

  setId: (id) ->
    @params.id = hash id.toString()

  save:(cb) ->
    save = () =>
      console.log 'save'
      multi = client.multi()
      multi.hmset @key(@params.id), @params
      multi.zadd @key("index"), Date.now(), @params.id
      multi.exec (err, replies) =>
        console.log 'rep'
        cb(err) if cb?


    if not @params.id?
      client.incr @key("next.id"), (err, next_id) =>
        @params.id = next_id
        throw err if err
        save()
    else
      save()

module.exports = Model
