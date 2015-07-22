# parse a spec

class Reference
  constructor: (@segments) ->

  toString: ->
    @segments.join '.'

class StringLiteral
  constructor: (@value) ->

  toString: ->
    escaped = @value.replace /\\/g, '\\\\'
    escaped = escaped.replace /"/g, '\\"'
    '"' + escaped + '"'

  walk: (walker) ->
    walker.walkStringLiteral @value

class NumberLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

  walk: (walker) ->
    walker.walkNumberLiteral @value

class BoolLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

  walk: (walker) ->
    walker.walkBooleanLiteral @value

class NullLiteral
  constructor: ->

  toString: ->
    'null'

  walk: (walker) ->
    walker.walkNullLiteral()

OPERATORS = [
  '+', '-', '*', '/'
  '<', '<='
  '>', '>='
  '=', '!='
  'and', 'or'
]

#  plus: '+'
#  minus: '-'
#  times: '*'
#  divide: '/'
#
#  equal: '='
#  notEqual: '!='
#  lessThan: '<'
#  atMost: '<='
#  greaterThan: '>'
#  atLeast: '>='

class BinaryOperation
  constructor: (@left, @operator, @right) ->

  toString: ->
    "(#{@left.toString()} #{@operator} #{@right.toString()})"

  walk: (walker) ->
    left = @left.walk walker
    right = @right.walk walker
    walker.walkBinaryOperation @operator, left, right

class NotSpecification
  constructor: (@spec) ->

class LogicalConjunction
  constructor: (@left, @right) ->

  toString: ->
    "(#{@left.toString()} and #{@right.toString()})"

  walk: (walker) ->
    left = @left.walk walker
    right = @right.walk walker
    walker.walkLogicalConjunction left, right

class LogicalDisjunction
  constructor: (@left, @right) ->

  toString: ->
    "(#{@left.toString()} or #{@right.toString()})"

  walk: (walker) ->
    left = @left.walk walker
    right = @right.walk walker
    walker.walkLogicalDisjunction left, right

class FunctionCall
  constructor: (@function, @parameters) ->

  toString: ->
    params = (param.toString() for param in @parameters)
    "#{@function.toString()}(#{params.join ', '})"

module.exports = {
  Reference

  StringLiteral
  NumberLiteral
  BoolLiteral
  NullLiteral

  BinaryOperation
  NotSpecification
  LogicalConjunction
  LogicalDisjunction

  FunctionCall

  OPERATORS
}
