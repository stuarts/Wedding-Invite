
module.exports = (name, Model) ->
  class RSVP extends Model
    constructor:(params) ->
      @name = name

      @mapping
        after_party: Model.Map.checked
        group_size: Model.Map.number

      @allowed "after_party"
      @required "email", "name"
      @required
        group_size: (val) -> !isNaN val

      super @name, params

