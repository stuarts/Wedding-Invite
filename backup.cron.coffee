{ exec, spawn }               = require 'child_process'
{ exists, resolve }           = require 'path'
{ job }                       = require 'cron'
knox                          = require 'knox'
{ createReadStream }          = require 'fs'
{ createWriteStream }         = require 'fs'

passphrase = process.env.RSVP_BACKUP_SECRET

client = knox.createClient
  key: process.env.RSVP_AWS_KEY
  secret: process.env.RSVP_AWS_SECRET
  bucket: 'playpen_app'

datetime =-> new Date().toString().replace /\s|:|GMT.*/g, "_"

call = (fn, options) -> if options.if? then fn options.if else null

crypto = (options={}, cb) ->
  sourceStream = options.sourceStream ? call createReadStream, if: options.source
  destStream = options.destStream ? call createWriteStream, if: options.dest

  if sourceStream?
    gpg = spawn 'gpg', options.arguments.concat if options?.passphrase?
                                                  ['--passphrase', options.passphrase]
                                                else
                                                  []
    gpg.stderr.setEncoding 'utf8'
    gpg.stderr.on 'data', console.log
    sourceStream.pipe gpg.stdin
    if destStream?
      gpg.stdout.pipe destStream

    gpg.stdout

  else
    null


encrypt = (options={})->
  options.arguments = [ '-c' ]
  crypto options

decrypt = (options={})->
  options.arguments = [ '--decrypt' ]
  crypto options


copy =(done)->
  filename = "#{ datetime() }dump.rdb"
  exec "cp /usr/local/var/db/redis/dump.rdb /tmp/#{filename}", (err, sterr, stout) ->
    done filename

enc =(filename, done)->
  encrypted_stream  = encrypt
    source:"/tmp/#{filename}"
    dest:"/tmp/#{filename}.gpg"
    passphrase: passphrase
  encrypted_stream.on "end", ->
    done "/tmp/#{filename}.gpg"

push =(source, filename, done)->
  client.putFile source, "/redis/#{filename}.gpg", (err, res) ->
    console.log res.statusCode
    console.log res.headers
    done "redis/#{filename}"

backup =->
  copy (filename)->
    enc filename, (encrypted_file)->
      push encrypted_file, filename, ->
        console.log 'done'

pull =(filename, dest)->
  req = client.get filename
  req.on 'response', (res)->
    console.log res.statusCode
    console.log res.headers
    decrypt sourceStream:res, dest: dest, passphrase: passphrase
  req.end()

exports.backup = backup

exports.pull = pull

cj = job "0 0 */8 * * *", ->
  backup()

exports.cron = cj
