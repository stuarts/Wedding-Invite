{ reqdir } = require "./helper"


module.exports = class Controller
  constructor:(controllers) ->
    @controllers = {}

  linkModelsControllers: (models, controllers) ->
    for key, factory of controllers
      Model = models[key]
      Child = factory(Controller, Model)
      controller = new Child
      load = @load
      controller.load = (id, fn) ->
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
    console.log 'id', id
    @model?.get id, fn
