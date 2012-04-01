module.exports = (Controller, Index) ->
  class Index extends Controller
    constructor:(controllers) ->
    index: (req, res) ->
      validation_errors = req.session.validation_errors ? []
      validation = (name) ->
        if name in validation_errors
          'needs_validation'
      rsvp =  req.body.rsvp ? req.session.rsvp ? group_size : 1
      delete req.session.rsvp
      delete req.session.validation_errors
      res.render 'index',
        title: "hello"
        validation: validation
        rsvp: rsvp

    new: (req, res) ->
    create: (req, res) =>
    show: (req, res) =>
    edit: (req, res) =>
    update: (req, res) =>
    destroy: (req, res) =>
