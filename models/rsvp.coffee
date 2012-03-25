
module.exports = (name, Model) ->
  class RSVP extends Model
    constructor:(params) ->
      @name = name
      @allowed "name", "after_party"
      @required "email", "group_size"
      super @name, params

