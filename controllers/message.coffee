async = () ->
  calls = {}
  result = {}
  doneCallback = null

  testDone = (name) ->
    delete calls[name]
    0 == (key for key of calls).length

  II:(name) ->
    callback = (args...)->
      result[name] = args
      done= testDone name
      doneCallback(result) if done and doneCallback?
    calls[name] = callback
    callback

  done:(callback) ->
    doneCallback = callback

module.exports = (Controller, Message) ->
  {validation} = Controller
  class MessageController extends Controller
    constructor:() ->

    index: (req, res) ->
      {II, done} = async()
      Message.all II 'messages'
      Message.models.RSVP.get req.session.rsvp_id, II 'rsvp' if req.session.rsvp_id?
      done (results)->
        { rsvp, messages } = results
        console.log messages
        res.render 'wall/index',
          title: "Message Wall"
          name: rsvp?[1].name
          messages: messages[0]

    create: (req, res) ->
      try
        rsvp = new Message(req.body.message).map().validate()
        rsvp.save (err)->
          throw err if err?
          res.redirect "/wall"
          #sendBackupMail rsvp
      catch e
        if e instanceof RSVP.ValidationError
          req.session.message = req.body.message
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'
        else
          throw e

    destroy: (req, res) ->
