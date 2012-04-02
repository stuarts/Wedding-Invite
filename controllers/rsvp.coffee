module.exports = (Controller, RSVP) ->
  class RSVPController extends Controller
    constructor:() ->

    index: (req, res) =>
      RSVP.all (rsvps) ->
        res.render 'rsvp/index',
          title: "RSVP"
          rsvps: rsvps

    search: (req, res) =>
      console.log 'atsearch'
      err = null
      if req.body?.email?
        RSVP.searchById req.body.email, (err, rsvp)->
          if not err? && rsvp?.params?.email == req.body.email
            res.redirect "/rsvps/#{rsvp.params.id}/edit"
          else
            req.flash 'info', "Could not find #{req.body.email}"
            res.redirect 'back'
      else
        res.render 'rsvp/search'
          title: "Find RSVP"
          err: req.flash 'info'

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

    edit: (req, res) =>
      validation_errors = req.session.validation_errors ? []
      validation = (name) ->
        if name in validation_errors
          'needs_validation'
      console.log req.rsvp.params
      res.render 'rsvp/edit',
        title: "Edit My RSVP"
        validation: validation
        method: 'put'
        rsvp: req.rsvp.params

    update: (req, res) ->
      try
        rsvp = new RSVP(req.body.rsvp).map().validate()
        rsvp.updateId rsvp.params.email
        console.log 'updated id'
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

    create: (req, res) =>
      try
        rsvp = new RSVP(req.body.rsvp).map().validate()
        rsvp.setId rsvp.params.email
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

