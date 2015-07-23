# parse a spec

class Reference
  constructor: (@segments) ->

  toString: ->
    @segments.join '.'

  walk: (walker) ->
    walker.walkReference @segments

  walkPreorder: (previous, walker) ->
    walker.walkReference previous, @segments

class StringLiteral
  constructor: (@value) ->

  toString: ->
    escaped = @value.replace /\\/g, '\\\\'
    escaped = escaped.replace /"/g, '\\"'
    '"' + escaped + '"'

  walk: (walker) ->
    walker.walkStringLiteral @value

  walkPreorder: (previous, walker) ->
    walker.walkStringLiteral previous, @value

class NumberLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

  walk: (walker) ->
    walker.walkNumberLiteral @value

  walkPreorder: (previous, walker) ->
    walker.walkNumberLiteral previous, @value

class BoolLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

  walk: (walker) ->
    walker.walkBooleanLiteral @value

  walkPreorder: (previous, walker) ->
    walker.walkBooleanLiteral previous, @value

class NullLiteral
  constructor: ->

  toString: ->
    'null'

  walk: (walker) ->
    walker.walkNullLiteral()

  walkPreorder: (previous, walker) ->
    walker.walkNullLiteral previous

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

  walkPreorder: (previous, walker) ->
    next = walker.walkBinaryOperation previous, @operator, @left, @right
    @left.walkPreorder next, walker
    @right.walkPreorder next, walker
    next

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

  walkPreorder: (previous, walker) ->
    next = walker.walkLogicalConjunction previous, @left, @right
    @left.walkPreorder next, walker
    @right.walkPreorder next, walker
    next

class LogicalDisjunction
  constructor: (@left, @right) ->

  toString: ->
    "(#{@left.toString()} or #{@right.toString()})"

  walk: (walker) ->
    left = @left.walk walker
    right = @right.walk walker
    walker.walkLogicalDisjunction left, right

  walkPreorder: (previous, walker) ->
    next = walker.walkLogicalDisjunction previous, @left, @right
    @left.walkPreorder next, walker
    @right.walkPreorder next, walker
    next

class FunctionCall
  constructor: (@function, @parameters) ->

  toString: ->
    params = (param.toString() for param in @parameters)
    "#{@function.toString()}(#{params.join ', '})"

  walk: (walker) ->
    fn = @function.walk walker
    params = (p.walk walker for p in @parameters)
    walker.walkFunctionCall fn, params

  walkPreorder: (previous, walker) ->
    next = walker.walkFunctionCall previous, @function, @parameters
    @function.walkPreorder next, walker
    for param in @parameters
      param.walkPreorder next, walker
    next

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
