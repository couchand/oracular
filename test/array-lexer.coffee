# array lexer for tests

{EOF} = require '../src/spec/tokens'
Token = require '../src/spec/token'

class ArrayLexer
  constructor: (@tokens=[]) ->

  getToken: ->
    unless @tokens.length
      return new Token EOF

    result = @tokens[0]
    @tokens = @tokens[1..]

    result

module.exports = ArrayLexer
