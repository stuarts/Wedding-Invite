{ reqdir } = require "../helper"


module.exports = class Controller
  constructor:(controllers) ->
    @controllers = {}

  linkModelsControllers: (models, controllers) ->
    for key, factory of controllers when factory != Controller
      Model = models[key]
      Child = factory(Controller, Model)
      @controllers[key] = new Child

    for key, model of models
      @controllers[key]?.link key, model
    @controllers.index = @

  setModels: (models) =>

  link: (key, model) => @model = model
  index: (req, res) =>
    res.render 'index',
      title: "Brynn and Stuart's Wedding!"
  new: (req, res) =>
  create: (req, res) =>
  show: (req, res) =>
  edit: (req, res) =>
  update: (req, res) =>
  destroy: (req, res) =>
  load: (id, fn) -> @model?.findOne id, fn
