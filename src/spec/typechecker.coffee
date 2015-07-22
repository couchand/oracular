# type checker

{
  SpecType
  TypeSpecifier
} = require './types'

class TypeChecker
  constructor: (@config) ->

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

module.exports = TypeChecker
