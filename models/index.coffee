redis = require 'redis'
{ reqdir } = require "../helper"

client = redis.createClient()

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
  @ValidationError = ValidationError
  constructor: (@name, params={})->
    @key = define @name
    @definitions = {}
    @params = {}
    @required "id"
    if not params.id?
      params.id = 'find_out'
    @set params

  allowed: (params...) ->
    for param in params
      @definitions[param] = 'allow'

  required: (params...) ->
    for param in params
      @definitions[param] = 'require'

  defineModels:(models) ->
    @models = models
    for key, definition of models
      @models[key] = definition key, Model if definition != Model
      model = define key
      static @models[key],
        all: (cb) ->
          client.lrange model('index'), 0, -1, (err, ids) ->
            if ids?
              multi = client.multi()
              for id in ids
                multi.hgetall model(id)
              multi.exec (err, replies) ->
                _models = for model_params in replies
                  new models[key] model_params
                cb _models
            else
              cb []

        get: (id, cb) ->
          client.get model(id), (err, model_params) ->
            cb new models[key] (model_params)

  set: (params) =>
    validation_errors = []
    for param, allowance in @definitions
      @params[param] = params[param]
      if allowance is "require" and not @params[param]?
        validation_errors.push param
    if validation_errors.length
      throw new ValidationError validation_errors

  save:(cb) =>

    client.incr @key("next.id"), (err, next_id) =>
      @params.id = next_id
      throw err if err
      multi = client.multi()
      multi.hmset @key(next_id), @params
      multi.rpush @key("index"), next_id
      multi.exec (err, replies) ->
        cb(err) if cb?

module.exports = Model
