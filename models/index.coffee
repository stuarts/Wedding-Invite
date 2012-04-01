
module.exports = (name, Model) ->
  class Index extends Model
    constructor:(params)->
      @name = name
      super name, params
