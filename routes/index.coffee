module.exports = (app, controllers) ->
  app.all /.*/, (req, res, next) ->
    host = req.header 'host'
    if        /brynnstuartwedwith\.us/    .test host then res.redirect "http://brynnandstuartwedding.info#{req.url}", 301
    else if   /^www\..*/i                 .test host then res.redirect "http://#{host.replace /www\./, ''}#{req.url}", 301
    else next()

  app.get '/wall', controllers.message.index
  app.resource 'messages', controllers.message
  app.resource 'users', controllers.user, (users) ->
    users.get '/login', controllers.user.login
    users.post '/login', controllers.user.login
  rsvps = app.resource "rsvps", controllers.rsvp, (rsvps) ->
    rsvps.get '/search', controllers.rsvp.search
    rsvps.post '/search', controllers.rsvp.search
  app.resource controllers.index
