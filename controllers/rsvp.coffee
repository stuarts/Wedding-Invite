module.exports = (Controller, RSVP) ->
  class RSVPController extends Controller
    constructor:() ->

    index: (req, res) =>
      RSVP.all (rsvps) ->
        res.render 'rsvp/index',
          title: "RSVP"
          rsvps: rsvps

    new: (req, res) ->
      layout = req.format isnt "ajax"
      validation_errors = req.session.validation_errors ? []
      validation = (name) ->
        if name in validation_errors
          'needs_validation'
      rsvp =  req.body.rsvp ? req.session.rsvp ? group_size : 1
      delete req.session.rsvp
      delete req.session.validation_errors
      res.render "rsvp/new",
        title: "RSVP"
        layout: layout
        validation: validation
        rsvp: rsvp

    create: (req, res) =>
      try
        new RSVP(req.body.rsvp).validate().save (err)->
          if err?
            throw err
          else
            res.redirect "/rsvps"
      catch e
        if e instanceof RSVP.ValidationError
          req.session.rsvp = req.body.rsvp
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'
