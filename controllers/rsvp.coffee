email = require 'mailer'

module.exports = (Controller, RSVP) ->
  sendBackupMail= (new_rsvp) ->

    RSVP.all (rsvps) ->
      body =  """
              Stuart,

              You have a new rsvp.

              New rsvp.
              #{JSON.stringify new_rsvp.params}

              Total rsvps: #{rsvps.length}
              #{JSON.stringify rsvps}
              ==================================
                -- Heroku App.
              """

      sgusername = process.env.SENDGRID_USERNAME
      sgpassword = process.env.SENDGRID_PASSWORD
      if sgusername? and sgpassword?
        email.send
            host : "smtp.sendgrid.net"
            port : "587"
            domain : "brynnstuartwedwith.us"
            to : "stredarts@gmail.com"
            from : "app@brynnstuartwedwith.us"
            subject : "Auto backup from your weding site"
            body: body
            authentication : "login"
            username : sgusername
            password : sgpassword
        , (err, result)->
          console.log err if err?

  {validation} = Controller
  class RSVPController extends Controller
    constructor:() ->

    index: (req, res) =>
      if req.session.authorized
        RSVP.all (rsvps) ->
          picnic_total = 0
          party_total = 0
          for rsvp in rsvps
            group_size = Number rsvp.group_size
            continue if isNaN group_size
            if rsvp.picnic == 'true'
              picnic_total += group_size
            if rsvp.after_party == 'true'
              party_total += group_size

          console.log rsvps
          res.render 'rsvp/index',
            title: "RSVP"
            rsvps: rsvps
            picnic_total: picnic_total
            party_total: party_total
      else
        res.redirect '/'

    search: (req, res) =>
      err = null
      if req.body?.email?
        RSVP.searchById req.body.email, (err, rsvp)->
          if not err? && rsvp?.params?.email == req.body.email
            res.redirect "/rsvps/#{rsvp.params.id}/edit"
          else
            req.flash 'info', "Umm, we don't have a reservation for any \"#{req.body.email}\"."
            res.redirect 'back'
      else
        res.render 'rsvp/search'
          title: "Find RSVP"
          err: req.flash 'info'

    new: (req, res) ->
      rsvp =  req.body.rsvp ? req.session.rsvp ? group_size : 1
      delete req.session.rsvp
      res.render "rsvp/new",
        validation: validation(req)
        method: 'post'
        title: "RSVP"
        rsvp: rsvp

    edit: (req, res) =>
      console.log req.rsvp
      res.render 'rsvp/edit',
        title: "Edit My RSVP"
        validation: validation(req)
        method: 'put'
        rsvp: req.rsvp.params

    update: (req, res) ->
      try
        rsvp = new RSVP(req.body.rsvp).map().validate()
        rsvp.updateId rsvp.params.email
        rsvp.save (err)->
          if err?
            throw err
          else
            req.session.rsvp_id = rsvp.params.id
            res.redirect "/"
            sendBackupMail rsvp
      catch e
        if e instanceof RSVP.ValidationError
          req.session.rsvp = req.body.rsvp
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'

    create: (req, res) =>
      try
        rsvp = new RSVP(req.body.rsvp)
        rsvp.map()
        rsvp.validate()
        rsvp.setId rsvp.params.email
        rsvp.save (err)->
          if err?
            throw err
          else
            req.session.rsvp_id = rsvp.params.id
            res.redirect "/"
            sendBackupMail rsvp
      catch e
        if e instanceof RSVP.ValidationError
          req.session.rsvp = req.body.rsvp
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'
        else
          throw e

    destroy: (req, res) ->
      if req.session.rsvp_id == req.body.rsvp.id
        delete req.session.rsvp_id
      new RSVP(req.body.rsvp).destroy()
      res.redirect '/rsvps'
