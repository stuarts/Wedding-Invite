module.exports = (Controller, RSVP) ->
  class RSVPController extends Controller
    constructor:() ->

    index: (req, res) =>
      RSVP.all (rsvps) ->
        res.render 'rsvp/index',
          title: "RSVP"
          rsvps: rsvps

    new: (req, res) ->
      res.render "rsvp/new",
        title: "RSVP"
        validation: req.validation ? () ->
        rsvp: if req.body.rsvp?
                req.body.rsvp
              else
                group_size: 1

    create: (req, res) =>
      try
        new RSVP(req.body.rsvp).validate().save (err)->
          if err?
            throw err
          else
            res.redirect "/rsvps"
      catch e
        if e instanceof RSVP.ValidationError
          req.validation = (name) ->
            if name in e.unmet_reqs
              'needs_validation'
          @new req, res
