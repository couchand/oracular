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

class NumberLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

class BoolLiteral
  constructor: (@value) ->

  toString: ->
    '' + @value

class NullLiteral
  constructor: ->

  toString: ->
    'null'

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

class NotSpecification
  constructor: (@spec) ->

class LogicalConjunction
  constructor: (@left, @right) ->

  toString: ->
    "(#{@left.toString()} and #{@right.toString()})"

class LogicalDisjunction
  constructor: (@left, @right) ->

  toString: ->
    "(#{@left.toString()} or #{@right.toString()})"

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
