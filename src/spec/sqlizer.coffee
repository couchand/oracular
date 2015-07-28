# sqlize a spec

BUILTINS = require './builtins'

escapeString = (str) ->
  str
    .replace /\\/g, "\\\\"
    .replace /'/g, "\\'"

class Sqlizer
  constructor: (@config) ->
    @config ?= {}
    @config.tables ?= {}
    @config.specs ?= {}

    @joins = {}

  serialize: (root, spec) ->
    tableName = root.table

    select = "[#{tableName}].[#{root.id or 'Id'}]"

    where = spec.walk @
    joins = (v for k, v of @joins).join '\n'

    from = "[#{tableName}]"

    """
    SELECT DISTINCT #{select}
    FROM #{from}
    #{joins}
    WHERE #{where}
    """

  hasTable: (needle) ->
    for table in @config.tables when table.table is needle
      return yes
    no

  getTable: (needle) ->
    for table in @config.tables when table.table is needle
      return table
    null

  hasSpec: (needle) ->
    for spec in @config.specs when spec.name is needle
      return yes
    no

  getSpec: (needle) ->
    for spec in @config.specs when spec.name is needle
      return spec
    null

  getParent: (table, name) ->
    for parent in table.parents when parent.name is name
      return parent
    null

  getField: (table, name) ->
    for field in table.fields when field.name is name
      return field
    null

  getTableName: (table) ->
    if table.table of @names
      @names[table.table]
    else
      @names[table.table] = @namer.getName table.table

  walkNullLiteral: ->
    "NULL"

  walkBooleanLiteral: (val) ->
    if val then "1" else "0"

  walkNumberLiteral: (num) ->
    "#{num}"

  walkStringLiteral: (str) ->
    "'#{escapeString str}'"

  walkBinaryOperation: (op, left, right) ->
    "(#{left} #{op} #{right})"

  walkLogicalConjunction: (left, right) ->
    "(#{left} AND #{right})"

  walkLogicalDisjunction: (left, right) ->
    "(#{left} OR #{right})"

  walkFunctionCall: (fn, args) ->
    throw 'up'

  walkReference: (ref) ->
    unless ref.length
      throw new Error "reference has no segments"

    if ref.length is 1 and @hasSpec ref[0]
      return ""

    if ref.length is 1 and ref[0].toLowerCase() of BUILTINS
      return ""

    unless @hasTable ref[0]
      throw new Error "sql error: reference unknown"

    root = @getTable ref[0]

    if ref.length is 1
      return "[#{root.table}]"

    if ref.length is 2
      parent = @getParent root, ref[1]
      if parent
        return "[#{parent.table}]"

      field = @getField root, ref[1]
      if field
        return "[#{root.table}].[#{field.name}]"

      throw new Error "sql error: field not found"

    table = root
    tableName = root.table

    for index in [1...ref.length-1]
      subset = ref[..index].join '.'

      previous = tableName
      parent = @getParent table, ref[index]
      table = @getTable parent.table
      tableName = "#{tableName}.#{parent.name}"

      unless subset of @joins
        @joins[subset] = """
          LEFT JOIN [#{parent.table}] [#{tableName}] ON [#{tableName}].[#{table.id or 'Id'}] = [#{previous}].[#{parent.id or parent.name + 'Id'}]
          """
    field = @getField table, ref[ref.length-1]
    "[#{tableName}].[#{field.name}]"

module.exports = Sqlizer
