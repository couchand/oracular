# spec parser

# expects a lexer which provides a getToken method

TokenType = require './token'
Node = require './ast'

PRECEDENCE =
  '*': 40
  '/': 40
  '+': 20
  '-': 20
  '<': 10
  '>': 10
  '<=': 10
  '>=': 10
  '=': 10
  '!=': 10
  and: 4
  or: 2

class Parser
  constructor: (lexer) ->
    unless @ instanceof Parser
      return new Parser lexer

    @lexer = lexer

    # prime the lookahead
    @currentToken = lexer.getToken()
    @nextToken = lexer.getToken()

  getNextToken: ->
    @currentToken = @nextToken
    @nextToken = @lexer.getToken()

  currentPrecedenceExceeds: (prec) ->
    @currentToken.type is TokenType.Operator and
      prec < PRECEDENCE[@currentToken.value.toLowerCase()]

  parseBinary: (lhs) ->
    unless @currentToken.type is TokenType.Operator
      throw new Error "Expected a binary operator"

    op = @currentToken.value
    prec = PRECEDENCE[op.toLowerCase()]

    @getNextToken()

    rhs = @parseCurrentToken()

    while @currentPrecedenceExceeds prec
      rhs = @parseBinary rhs

    if /^and$/i.test op
      new Node.AndSpecification lhs, rhs
    else if /^or$/i.test op
      new Node.OrSpecification lhs, rhs
    else
      new Node.BinaryOperation lhs, op, rhs

  parseReference: ->
    ref = new Node.Reference @currentToken.value

    if @nextToken.type isnt TokenType.OpenParen
      return ref

    @getNextToken() # consume reference
    @getNextToken() # consume openparen

    params = []

    loop
      params.push @parseCurrentToken()

      break if @currentToken.type is TokenType.CloseParen

      unless @currentToken.type is TokenType.Comma
        throw new Error "Expected a comma or close paren: #{@currentToken.toString()}"

      @getNextToken() # consume comma

    new Node.FunctionCall ref, params

  parseCurrentToken: ->
    result = switch @currentToken.type
      when TokenType.EOF
        throw new Error 'Not enough input'

      when TokenType.Number
        new Node.NumberLiteral @currentToken.value

      when TokenType.String
        new Node.StringLiteral @currentToken.value

      when TokenType.Reference
        segments = @currentToken.value
        if segments.length is 1
          switch on
            when /^null$/i.test segments[0]
              new Node.NullLiteral
            when /^true$/i.test segments[0]
              new Node.BoolLiteral yes
            when /^false$/i.test segments[0]
              new Node.BoolLiteral no
            else
              @parseReference()

        else
          @parseReference()

      when TokenType.OpenParen
        @getNextToken() # consume open paren

        tok = @parseKernel()

        if @currentToken.type isnt TokenType.CloseParen
          throw new Error "Too much input: #{@currentToken.toString()}"

        @getNextToken() # consume close paren

        tok

      else
        throw new Error "Case undefined: #{@currentToken.toString()}"

    @getNextToken()

    result

  parseKernel: ->
    result = @parseCurrentToken()

    while @currentToken.type is TokenType.Operator
      result = @parseBinary result

    result

  parse: ->
    result = @parseKernel()

    if @currentToken.type isnt TokenType.EOF
      throw new Error "Too much input: #{@currentToken.toString()}"

    result

module.exports = Parser
