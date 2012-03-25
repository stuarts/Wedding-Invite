module.exports = (app, controllers) ->
  app.resource "rsvps", controllers.rsvp
  app.resource controllers.index
