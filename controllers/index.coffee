module.exports = (Controller, Index) ->
  class Index extends Controller
    constructor:(controllers) ->
    index: (req, res) =>
      res.render 'index',
        title: "hello"

    new: (req, res) =>
    create: (req, res) =>
    show: (req, res) =>
    edit: (req, res) =>
    update: (req, res) =>
    destroy: (req, res) =>
