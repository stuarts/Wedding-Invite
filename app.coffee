
# Module dependencies.

express = require 'express'
resource = require 'express-resource'
redis = require 'redis-url'
{reqdir, link_mvc} = require './helper'
RedisStore = require('connect-redis')(express)

app = module.exports = express.createServer()

client = null

# Configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.cookieParser()
  app.use express.session secret: "brynn and me walking down a beach", store: new RedisStore
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require('stylus').middleware src: __dirname + '/public'
  app.use require('express-coffee')
    path: __dirname+'/public'
    live: true
    uglify: false
    debug: true
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  client = redis.connect()
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  client = redis.connect(process.env.REDISTOGO_URL)
  app.use express.errorHandler()

# Routes

models = reqdir "./models"
controllers = reqdir "./controllers"

application_model = new models.index 'index'
application_model.defineModels models, client
application_controller = new controllers.index
application_controller.linkModelsControllers models, controllers

routes = require('./routes') app, application_controller.controllers

app.listen 9000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
