
module.exports = (name, Model) ->
  class Message extends Model
    constructor:(params) ->
      @name = name

      @required "name", "text"

      super @name, params

