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
        validation: validation
        method: 'post'
        title: "RSVP"
        layout: layout
        rsvp: rsvp

    create: (req, res) =>
      try
        rsvp = new RSVP(req.body.rsvp).validate()
        rsvp.setId rsvp.params.id
        rsvp.save (err)->
          if err?
            throw err
          else
            req.session.rsvp_id = rsvp.params.id
            res.redirect "/"
      catch e
        if e instanceof RSVP.ValidationError
          req.session.rsvp = req.body.rsvp
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'

    edit: (req, res) =>
      res.render 'rsvp/edit',
        title: "Edit My RSVP"
        validation: ()->
        method: 'put'
        rsvp: req.rsvp.params


    update: (req, res) ->
      try
        console.log req.body
        rsvp = new RSVP(req.body.rsvp).validate()
        rsvp.setId rsvp.params.id
        rsvp.save (err)->
          if err?
            throw err
          else
            req.session.rsvp_id = rsvp.params.id
            res.redirect "/"
      catch e
        if e instanceof RSVP.ValidationError
          req.session.rsvp = req.body.rsvp
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'



