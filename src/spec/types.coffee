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

  coalesce: (other) ->
    if @type is other.type then @ else null

class TableTypeSpecifier
  constructor: (@table) ->
    @type = SpecType.Table

  toString: ->
    @table

  coalesce: (other) ->
    if @type is other.type and @table is other.table then @ else null

class FunctionTypeSpecifier
  constructor: (@returnType, @parameterTypes) ->
    @type = SpecType.Function

  toString: ->
    params = (p.toString() for p in @parameterTypes)
    @returnType.toString() + " (" + params.join(', ') + ")"

  coalesce: (other) ->
    return null unless other.type is @type

    ret = @returnType.coalesce other.returnType
    return null unless ret

    params = []
    for i, p of @parameterTypes
      param = p.coalesce other.parameterTypes[+i]
      return null unless param
      params.push param

    new FunctionTypeSpecifier ret, params

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
