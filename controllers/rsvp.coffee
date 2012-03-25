module.exports = (Controller) ->
  class RSVPController extends Controller
    constructor:() ->
    index: (req, res) =>
      @RSVP.all (rsvps) ->
        rsvp_data = (rsvp.params for rsvp in rsvps)
        res.render 'rsvp/index',
          title: "RSVP"
          rsvps: rsvp_data
    new: (req, res) ->
      console.log flash 'error'
      res.render "rsvp/new",
        title: "RSVP"
    create: (req, res) =>
      try
        new @RSVP(req.body.rsvp).save (err)->
          if err?
            throw err
          else
            res.redirect "/rsvps"
      catch e
        if e instanceof Model.ValidationError
          console.log e
          for req_field in e.unmet_reqs
            req.flash 'error', "You must set #{req_field}"
          res.redirect 'back'

    link:(key, @RSVP) =>
      @model = @RSVP
