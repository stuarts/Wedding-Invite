module.exports = (app, controllers) ->
  app.get '/wall', controllers.message.index
  app.resource 'messages', controllers.message
  app.resource 'users', controllers.user, (users) ->
    users.get '/login', controllers.user.login
    users.post '/login', controllers.user.login
  rsvps = app.resource "rsvps", controllers.rsvp, (rsvps) ->
    rsvps.get '/search', controllers.rsvp.search
    rsvps.post '/search', controllers.rsvp.search
  app.resource controllers.index
