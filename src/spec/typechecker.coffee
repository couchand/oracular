# type checker

{
  SpecType
  TypeSpecifier
} = require './types'

class TypeChecker
  constructor: (@config) ->
    @config ?= {}
    @config.tables ?= []
    @config.specs ?= []

  hasTable: (needle) ->
    for table in @config.tables when table.table is needle
      return yes

  getTable: (needle) ->
    for table in @config.tables when table.table is needle
      return table
    null

  hasSpec: (needle) ->
    for spec in @config.specs when spec.name is needle
      return yes

  getSpec: (needle) ->
    for spec in @config.specs when spec.name is needle
      return spec
    null

  walkNullLiteral: ->
    TypeSpecifier.any

  walkBooleanLiteral: ->
    TypeSpecifier.boolean

  walkNumberLiteral: ->
    TypeSpecifier.number

  walkStringLiteral: ->
    TypeSpecifier.string

  walkBinaryOperation: (op, left, right) ->
    switch op
      when '+', '-', '*', '/'
        if left.type isnt SpecType.Number or right.type isnt SpecType.Number
          throw new Error "typecheck error: invalid type for #{op}: #{left.toString()} and #{right.toString()}"

        left

      when '=', '!=', '<', '<=', '>', '>='
        if left.type is SpecType.Any or right.type is SpecType.Any
          if op is '=' or op is '!='
            return TypeSpecifier.boolean
          else
            throw new Error "typecheck error: invalid type for #{op}: #{left.toString()} and #{right.toString()}"

        if left.type isnt right.type
          throw new Error "typecheck error: incompatible types for #{op}: #{left.toString()} and #{right.toString()}"

        if left.type is SpecType.Boolean and op isnt '=' and op isnt '!='
          throw new Error "typecheck error: invalid type for #{op}: #{left.toString()} and #{right.toString()}"

        TypeSpecifier.boolean

      else
        throw new Error "typecheck error: unknown case: #{op}"

  walkLogicalConjunction: (left, right) ->
    if left.type isnt SpecType.Boolean or right.type isnt SpecType.Boolean
      throw new Error "typecheck error: invalid type for conjunction: #{left.toString()} and #{right.toString()}"

    TypeSpecifier.boolean

  walkLogicalDisjunction: (left, right) ->
    if left.type isnt SpecType.Boolean or right.type isnt SpecType.Boolean
      throw new Error "typecheck error: invalid type for disjunction: #{left.toString()} and #{right.toString()}"

    TypeSpecifier.boolean

  walkReference: (segments) ->
    unless segments?.length
      throw new Error "reference has no segments"

    root = segments[0]
    unless @hasTable root
      if segments.length is 1 and @hasSpec root
        spec = @getSpec root
        if spec
          return TypeSpecifier.getFunction TypeSpecifier.boolean, [TypeSpecifier.getTable spec.table]

      throw new Error "typecheck error: name not found #{root}"

    table = @getTable root
    if segments.length is 1
      return TypeSpecifier.getTable table.table

    @getFieldInTable table, segments[1..]

  getField: (table, needle) ->
    return null unless table.fields
    for field in table.fields when field.name is needle
      return field
    null

  getParent: (table, needle) ->
    return null unless table.parents
    for parent in table.parents when parent.name is needle
      return parent
    null

  mapFieldType: (type) ->
    switch type
      when 'boolean' then TypeSpecifier.boolean
      when 'number' then TypeSpecifier.number
      when 'string' then TypeSpecifier.string
      when 'date' then TypeSpecifier.date
      else throw new Error "unknown field type #{type}"

  getFieldInTable: (table, segments) ->
    unless segments.length
      throw new Error "reference has no segments"

    if segments.length is 1
      field = @getField table, segments[0]
      if field
        return @mapFieldType field.type

      parent = @getParent table, segments[0]
      if parent
        return TypeSpecifier.getTable parent.table or parent.name

      throw new Error "typecheck error: field not found #{segments[0]}"

    parent = @getParent table, segments[0]
    unless parent
      throw new Error "typecheck error: parent table not found #{segments[0]}"

    parentTable = @getTable parentTableName = parent.table or parent.name
    unless parentTable
      throw new Error "typecheck error: parent table not found #{parentTableName}"

    @getFieldInTable parentTable, segments[1..]

  walkFunctionCall: (fnTy, paramTys) ->
    ps = fnTy.parameterTypes.length
    as = paramTys.length
    if ps isnt as
      throw new Error "typecheck error: function called with the wrong number of parameters: expected #{ps}, got #{as}"

    for i, p of fnTy.parameterTypes
      coalesced = p.coalesce paramTys[+i]
      unless coalesced
        throw new Error "typecheck error: function argument type mismatch #{p.toString()} and #{paramTys[+i].toString()}"

    fnTy.returnType

module.exports = TypeChecker
