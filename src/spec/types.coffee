# spec types

SpecType =
  Any:      0

  Boolean:  1
  Number:   2
  String:   3
  Date:     4

  Table:    5
  Function: 6

TYPES = [
  'Any'
  'Boolean'
  'Number'
  'String'
  'Date'
  'Table'
  'Function'
]

class SimpleTypeSpecifier
  constructor: (@type) ->

  toString: ->
    TYPES[@type]

class TableTypeSpecifier
  constructor: (@table) ->
    @type = SpecType.Table

  toString: ->
    @table

class FunctionTypeSpecifier
  constructor: (@returnType, @parameterTypes) ->
    @type = SpecType.Function

  toString: ->
    params = (p.toString() for p in @parameterTypes)
    @returnType.toString() + " (" + params.join(', ') + ")"

TypeSpecifier =
  any:      new SimpleTypeSpecifier SpecType.Any
  boolean:  new SimpleTypeSpecifier SpecType.Boolean
  number:   new SimpleTypeSpecifier SpecType.Number
  string:   new SimpleTypeSpecifier SpecType.String
  date:     new SimpleTypeSpecifier SpecType.Date
  getTable:    (t) -> new TableTypeSpecifier t
  getFunction: (r, p) -> new FunctionTypeSpecifier r, p

module.exports = {
  SpecType
  TypeSpecifier
}
