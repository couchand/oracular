# check the structure of references
# uses a preorder-walk

BUILTINS = require './builtins'

id = (previous) -> previous

class RefChecker
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

  # literals don't affect reference checking
  walkNullLiteral: id
  walkBooleanLiteral: id
  walkNumberLiteral: id
  walkStringLiteral: id

  # binary operation doesn't affect reference checking
  walkBinaryOperation: id

  # logical operations don't affect reference checking
  walkLogicalConjunction: id
  walkLogicalDisjunction: id

  # reference must be to one of the currently-joined tables
  walkReference: (tables, segments) ->
    unless segments.length
      throw new Error "reference has no segments"

    if segments.length is 1 and segments[0].toLowerCase() of BUILTINS
      # reference to builtin, ok
      return tables

    unless segments[0] in tables
      if segments.length is 1 and @hasSpec segments[0]
        # reference is to a valid spec, ok
        return tables

      throw new Error "refcheck error: reference is not to a joined table: #{segments[0]}"

    unless @hasTable segments[0]
      throw new Error "refcheck error: referenced table not found"

    tables # keep the same join tables

  # function call can add join tables
  walkFunctionCall: (tables, fn, args) ->
    unless fn.segments.length is 1
      throw new Error "function reference has invalid segment count"

    name = fn.segments[0].toLowerCase()

    if name of BUILTINS
      unless args.length and args[0].segments?.length
        throw new Error "refcheck error: builtin requires reference parameter"

      ref = args[0].segments[0]
      return [ref].concat tables

    # ignore others
    tables

module.exports = RefChecker
