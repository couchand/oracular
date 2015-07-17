# parse a spec to an ast

lex = require './spec/lexer'
parse = require './spec/parser'

module.exports = (spec) ->
  lexer = lex spec
  return unless lexer

  parser = parse lexer
  return unless parser

  parser.parse()
