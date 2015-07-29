# sqlize a spec

BUILTINS = require './builtins'

escapeString = (str) ->
  str
    .replace /\\/g, "\\\\"
    .replace /'/g, "\\'"

class Sqlizer
  constructor: (@config, @alias) ->
    @config ?= {}
    @config.tables ?= {}
    @config.specs ?= {}

    @joins = {}

  serialize: (root, spec) ->
    tableName = root.table

    select = "[#{@alias or tableName}].[#{root.id or 'Id'}]"

    where = spec.walk @
    joins = (v for k, v of @joins).join '\n'

    from = "[#{tableName}] [#{@alias or tableName}]"

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
    if @hasSpec fn
      spec = @getSpec fn

      unless spec?.spec?.walk
        throw new Error "sql error: spec not parsed"

      unless args.length is 1
        throw new Error "spec reference has invalid argument count"

      arg = args[0]

      builder = new Sqlizer @config, arg
      where = spec.spec.walk builder

      for k, v of builder.joins when k not of @joins
        @joins[k] = v

      where

    else
      throw new Error "builtins not yet supported"

  walkReference: (ref) ->
    unless ref.length
      throw new Error "reference has no segments"

    if ref.length is 1 and @hasSpec ref[0]
      return ref[0]

    if ref.length is 1 and ref[0].toLowerCase() of BUILTINS
      return ""

    unless @hasTable ref[0]
      throw new Error "sql error: reference unknown"

    root = @getTable ref[0]

    if ref.length is 1
      return "[#{@alias or root.table}]"

    if ref.length is 2
      parent = @getParent root, ref[1]
      if parent
        table = @getTable parent.table
        rel = (@alias or root.table) + '.' + parent.name
        @joins[rel] = """
          LEFT JOIN [#{parent.table}] [#{rel}] ON [#{rel}].[#{table.id or 'Id'}] = [#{@alias or root.table}].[#{parent.id or parent.name + 'Id'}]
          """
        return rel

      field = @getField root, ref[1]
      if field
        return "[#{@alias or root.table}].[#{field.name}]"

      throw new Error "sql error: field not found"

    table = root
    tableName = @alias or root.table

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
