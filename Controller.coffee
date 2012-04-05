{ reqdir } = require "./helper"


module.exports = class Controller
  constructor:(controllers) ->
    @controllers = {}

  @validation: (req) ->
    validation_errors = req.session.validation_errors ? []
    delete req.session.validation_errors
    (name) -> 'needs_validation' if name in validation_errors

  linkModelsControllers: (models, controllers) ->
    for key, factory of controllers
      Model = models[key]
      Child = factory(Controller, Model)
      controller = new Child
      controller.name = key
      load = @load
      controller.load = do (controller) ->
        (id, fn) -> 
          (load).call(controller, id, fn)
      @controllers[key] = controller

    for key, model of models
      @controllers[key]?.link key, model

  setModels: (models) =>

  link: (key, model) ->
    @model = model

  index: (req, res) ->
  new: (req, res) ->
  create: (req, res) ->
  show: (req, res) ->
  edit: (req, res) ->
  update: (req, res) ->
  destroy: (req, res) ->
  load: (id, fn) ->
    @model?.get id, fn
