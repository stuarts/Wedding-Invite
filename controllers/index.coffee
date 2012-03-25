{ reqdir } = require "../helper"


module.exports = class Controller
  constructor:(controllers) ->
    @controllers = {}
    for key, factory of controllers when factory != Controller
      Child = factory(Controller)
      @controllers[key] = new Child
    @controllers.index = @

  setModels: (models) =>
    for key, model of models
      @controllers[key]?.link key, model

  link: (key, model) => @model = model
  index: (req, res) =>
    res.render 'index',
      title: "hello"
  new: (req, res) =>
  create: (req, res) =>
  show: (req, res) =>
  edit: (req, res) =>
  update: (req, res) =>
  destroy: (req, res) =>
  load: (id, fn) -> @model?.findOne id, fn
