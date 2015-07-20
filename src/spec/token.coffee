# lexer tokens

module.exports = TOKENS =
  EOF:        0
  Reference:  1
  String:     2
  Number:     3
  Operator:   4
  OpenParen:  5
  CloseParen: 6
  Comma:      7

types = []
for name, type of TOKENS
  types[type] = name

class Token
  constructor: (@type, @value) ->

  toString: ->
    "Token[#{types[@type]}]#{if @value then @value else ''}"

module.exports.Token = Token
