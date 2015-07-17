# specification lexer

TOKEN_RE = ///
  ^ # match from start
  (
    [a-zA-Z_][a-zA-Z0-9_]* (\.[a-zA-Z_][a-zA-Z0-9_]*)* |  # reference
    ' (?:\\.|[^'])* '?    | # single-quoted string
    " (?:\\.|[^"])* "?    | # double-quoted string
    -?[0-9]+(\.[0-9]+)?   | # number
    (<=|>=|!=|[-+*/=!<>]) | # operator
    [(),]                 | # function call delimiters
    \#[^\n\r]*            | # comment
    \s+                     # ignore whitespace
  )
///

IGNORE_RE = /^(\s+|#[^\n\r]*)$/
OPERATOR_RE = /^(<=|>=|!=|[-+*/=!<>]|and|or)$/i
NUMBER_RE = /^-?[0-9]+(\.[0-9]+)?$/
STRING_RE = /^('(?:\\.|[^'])*'?|"(?:\\.|[^"])*"?)$/
CLOSED_STRING_RE = /^('(?:\\.|[^'])*'|"(?:\\.|[^"])*")$/
REFERENCE_RE = /^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*$/
OPEN_PAREN_RE = /^\($/
CLOSE_PAREN_RE = /^\)$/
COMMA_RE = /^,$/

TokenType = require './tokens'
Token = require './token'

class StringLexer
  constructor: (source='') ->
    unless @ instanceof StringLexer
      return new StringLexer source

    @source = source

  accept: (match) ->
    @source = @source[match.length..]
    match

  getToken: ->
    unless @source.length
      return new Token TokenType.EOF

    matches = TOKEN_RE.exec @source

    unless matches
      throw new Error "Invalid input: #{@source}"

    match = @accept matches[0]

    if IGNORE_RE.test match
      return @getToken()

    if OPEN_PAREN_RE.test match
      return new Token TokenType.OpenParen

    if CLOSE_PAREN_RE.test match
      return new Token TokenType.CloseParen

    if COMMA_RE.test match
      return new Token TokenType.Comma

    if OPERATOR_RE.test match
      return new Token TokenType.Operator, match.toLowerCase()

    if NUMBER_RE.test match
      return new Token TokenType.Number, +match

    if STRING_RE.test match
      unless CLOSED_STRING_RE.test match
        throw new Error "String is not closed: #{match}"

      matcher = new RegExp '\\\\' + match[0], 'g'
      str = match[1...-1].replace matcher, match[0]
      return new Token TokenType.String, str

    if REFERENCE_RE.test match
      parts = match.split '.'
      return new Token TokenType.Reference, parts

    throw new Error "Token invalid: #{match}"

module.exports = StringLexer
