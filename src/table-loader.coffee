# load table config

TYPES =
  string: 'string'
  number: 'number'
  bool: 'bool'
  date: 'date'

class Table
  constructor: (@table, @id, @parents, @fields) ->
    @key = 'table-' + @table

class Parent
  constructor: (@name, @table, @id) ->
    @id ?= @name + 'Id'
    @table ?= @name

    @key = 'parent-' + @name

class Field
  constructor: (@name, @type) ->
    @type ?= TYPES.string

    @key = 'field-' + @name

class TableError
  constructor: (@config) ->

module.exports = (config) ->
  tables = []
  errors = []

  for row in config
    unless row.table and row.fields
      errors.push new TableError row
      continue

    parents = for parent in row.parents or []
      new Parent parent.name, parent.table, parent.id

    fields = for field in row.fields
      new Field field.name, field.type

    id = row.id or 'Id'

    tables.push new Table row.table, id, parents, fields

  {tables, errors}
