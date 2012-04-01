{ reqdir } = require "./helper"
{ createHash } = require 'crypto'

client = null

model = null
define = (name) ->
  model = (subs...) -> "#{name}s" + if subs?
                                   ":#{subs.join ":"}"
                                 else
                                   ""
static = (to, from) ->
  for key, value of from
    to[key] = value

class ValidationError extends Error
  constructor:(@unmet_reqs) ->

class Model
  @Map =
    checked: (val) -> val == 'on'
    number: (val) -> Number(val)
    boolean: (should_be) -> (val) -> should_be == val

  @ValidationError = ValidationError
  constructor: (@name, params={})->
    @key = define @name
    @required "id"
    if not params.id?
      params.id = 'find_out'
    @set params

  mapping: (@maps) ->

  map: (data) ->
    for key, mapper of @maps
      data[key] = mapper data[key]
    @

  set: (params) ->
    @params = @params ? {}
    for param, allowance of @definitions
      @params[param] = params[param]
    @params

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
    client = _client
    @models = models
    for key, definition of models
      @models[key] = definition key, Model if definition != Model
      model = define key
      static @models[key],
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

        get: (id, cb) ->
          client.hgetall model(id), (err, model_params) ->
            cb err, new models[key] (model_params)

        ValidationError: ValidationError


  setId: (id) ->
    shasum = createHash 'sha1'
    shasum.update id
    @params.id = shasum.digest 'base64'


  save:(cb) ->
    save = () =>
      multi = client.multi()
      multi.hmset @key(@params.id), @params
      multi.zadd @key("index"), Date.now(), @params.id
      multi.exec (err, replies) =>
        cb(err) if cb?

    if @params.id is 'find_out'
      client.incr @key("next.id"), (err, next_id) =>
        console.log next_id, 'next_id'
        @params.id = next_id
        throw err if err
        save()
    else
      save()

module.exports = Model
