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

module.exports = (Controller, Message, models) ->
  {validation} = Controller
  RSVP = models.rsvp
  class MessageController extends Controller
    constructor:() ->

    index: (req, res) ->
      {II, done} = async()
      Message.all II 'messages'
      RSVP.get req.session.rsvp_id, II 'rsvp' if req.session.rsvp_id?
      done (results)->
        { rsvp, messages } = results
        res.render 'wall/index',
          title: "Message Wall"
          name: rsvp?[1]?.params?.name
          messages: messages[0]

    create: (req, res) =>
      try
        message = new Message(req.body.message).map().validate()

        {II, done} = async()
        save_done = II 'save'
        message.save (err)->
          throw err if err?
          res.redirect "/wall"
          save_done()
        RSVP.get req.session.rsvp_id, II 'rsvp' if req.session.rsvp_id?

        done (results)=>
          rsvp = results.rsvp?[1]
          console.log @
          @mail "stredarts@gmail.com, brynntownsend@gmail.com"
          , "New wedding message from #{message.params.name}"
          , """
            Hey Brynn & Stuart,

            You've got a message from: #{rsvp?.params?.email}

            They said:

            #{message.params.text}
            """

      catch e
        if e instanceof RSVP.ValidationError
          req.session.message = req.body.message
          req.session.validation_errors = e.unmet_reqs
          res.redirect 'back'
        else
          throw e

    destroy: (req, res) ->
