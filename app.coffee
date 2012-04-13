
# Module dependencies.

express = require 'express'
resource = require 'express-resource'
redis = require 'redis'
url = require 'url'
{reqdir, link_mvc} = require './helper'

{ cron } = require './backup.cron'


RedisStore = require('connect-redis')(express)

Controller = require './Controller'
Model = require './Model'

models = reqdir "./models"
controllers = reqdir "./controllers"


app = module.exports = express.createServer()

client = null

# Configuration
client = redis.createClient()

client.on "error", (err) ->
    console.log ("Error " + err)

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.cookieParser()
  app.use express.session
    secret: "brynn and me walking down a beach",
    store: new RedisStore( client:client )
    cookie: { maxAge: 1000 * 60 * 60 * 24 * 108 }
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require('stylus').middleware src: __dirname + '/public'
  app.use require('express-coffee')
    path: __dirname+'/public'
    live: true
    uglify: false
    debug: true
  app.use express.favicon __dirname + '/public/favicon.ico'
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  cron.start()
  app.use express.errorHandler()

# Routes


application_model = new Model 'app'
application_model.defineModels models, client

application_controller = new Controller
application_controller.linkModelsControllers models, controllers

routes = require('./routes') app, application_controller.controllers

app.listen if "production" is process.env.NODE_ENV
             80
           else
             9000

console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
