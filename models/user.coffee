
module.exports = (name, Model) ->
  {hash, client, define} = Model
  class User extends Model
    constructor:(params) ->
      @name = name
      @allowed 'salt'
      @required "email", "perm_token"
      super @name, params

    @create:(email, passphrase, cb) ->
      errors = []
      if not email or email == ""
        errors.push 'email'
      if not passphrase or passphrase == ''
        errors.push 'passphrase'
      return cb new User.ValidationError errors if errors.length
      User.searchById email, (err, user) ->
        if user?.params?.email == email
          console.log 'throw already made email'
          cb new User.ValidationError ['email']
        else
          salt = Math.floor(Math.random()*100000).toString(16)
          perm_token =  User.get_perm_token email, passphrase, salt
          user = new User { email, perm_token, salt }
          user.setId email
          cb null, user

    @authorize:(email, passphrase, cb) ->
      errors = []
      if not email or email == ""
        errors.push 'email'
      if not passphrase or passphrase == ''
        errors.push 'passphrase'
      return cb new User.ValidationError errors if errors.length
      User.searchById email, (err, user) ->
        if user?.params?.email == email
          salt = user.params.salt

          perm_token =  User.get_perm_token email, passphrase, salt
          if perm_token == user.params.perm_token
            cb(null, user)
          else
            cb new User.ValidationError['passphrase']
        else
          cb new User.ValidationError ['email']


    getIsAdmin:(cb) ->
      client.sismember "admin", @params.id, (err, res) ->
        console.log res, !!(+res)
        cb(err, !!(+res))

    @get_perm_token:(username, passphrase, salt) ->
      last = 'start'
      for i in [0..5]
        last = hash username+passphrase+salt+last
      last

