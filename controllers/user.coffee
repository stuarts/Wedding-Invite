
module.exports = (Controller, User) ->
  {validation} = Controller
  class UserController extends Controller
    constructor:(controllers) ->

    login: (req, res) ->
      if req.body.user
        {email, passphrase} = req.body.user
        User.authorize email, passphrase, (err, user) ->
          if not err?
            req.session.user_id = user.params.id
            user.getIsAdmin (err, isAdmin) ->
              req.session.authorized = isAdmin
              res.redirect "/users/#{user.params.id}"
          else if err instanceof User.ValidationError
            req.session.user = req.body.user
            req.session.validation_errors = err.unmet_reqs
            res.redirect 'back'
          else
            throw err
      else
        user = req.session.user
        delete req.session.user
        res.render 'user/login',
          title: 'Login'
          email: user?.email
          validation: validation(req)

    index: (req, res) ->
      res.redirect '/'

    new: (req, res) ->
      user = req.session.user
      delete req.session.user
      res.render 'user/new'
        title: "Sign up."
        email: user?.email
        passphrase: user?.passphrase
        validation: validation(req)

    create: (req, res) ->
      {passphrase, email} = req.body.user
      User.create email, passphrase, (err, user) ->
        if not err?
          user.save (err)->
          req.session.user_id = user.params.id
          user.getIsAdmin (err, isAdmin) ->
            req.session.authorized = isAdmin
            res.redirect "/users/#{user.params.id}"
        else if err instanceof User.ValidationError
          req.session.user = req.body.user
          req.session.validation_errors = err.unmet_reqs
          res.redirect 'back'
        else
          throw err

    show: (req, res) ->
      user = req.user
      if user?
        res.render 'user/show',
          title: "User Account"
          email: user.params.email

    edit: (req, res) ->
    update: (req, res) ->
    destroy: (req, res) ->

