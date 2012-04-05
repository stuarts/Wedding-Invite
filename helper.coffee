fs = require "fs"
path = require "path"

exports.reqdir = (include_path) ->
  namespace = {}
  files = fs.readdirSync path.resolve include_path
  for file in files when /\.js|\.coffee/.test file
    file_name = file.replace /\.js|\.coffee/, ""
    file_path = path.resolve __dirname, include_path, file_name
    namespace[file_name] = require file_path
  namespace

exports.link_mvc = (controllers, models, provider) ->
  for name, controller of controllers
    model = models[name]
    controller if model?
      model provider
    else
      redis
