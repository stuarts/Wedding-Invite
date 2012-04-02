module.exports = (app, controllers) ->
  rsvps = app.resource "rsvps", controllers.rsvp, (rsvps) ->
    rsvps.get '/search', controllers.rsvp.search
    rsvps.post '/search', controllers.rsvp.search
  app.resource controllers.index
