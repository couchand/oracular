# token class

types = []
for name, type of require './tokens'
  types[type] = name

class Token
  constructor: (@type, @value) ->

  toString: ->
    "Token[#{types[@type]}]#{if @value then @value else ''}"

module.exports = Token
