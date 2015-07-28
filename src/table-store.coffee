# table store

Reflux = require 'reflux'

makeId = require './make-id'
actions = require './table-actions'

tables = []
tablesById = {}
fieldsById = {}
parentsById = {}

nameTable = (prefix) ->
  count = 0

  for table in tables when table.table[...prefix.length] is prefix
    count += 1

  if count is 0
    prefix
  else
    tableNames = tables.map (t) -> t.table
    while (suggestion = prefix + (1 + count)) in tableNames
      count += 1
    suggestion

nameField = (table, prefix) ->
  count = 0

  for field in table.fields when field.name[...prefix.length] is prefix
    count += 1

  if count is 0
    prefix
  else
    fieldNames = table.fields.map (f) -> f.name
    while (suggestion = prefix + (1 + count)) in fieldNames
      count += 1
    suggestion

addTable = ->
  newTable =
    _id: makeId()
    table: nameTable 'NewTable'
    id: 'Id'
    parents: []
    fields: []

  field = addField newTable
  field.name = 'Id'

  tablesById[newTable._id] = newTable
  tables.push newTable

  newTable

addField = (table) ->
  newField =
    _id: makeId()
    _table: table
    name: nameField table, 'NewField'
    type: 'string'

  fieldsById[newField._id] = newField
  table.fields.push newField

  newField

pickTable = (table) ->
  used = {}
  for parent in table.parents
    used[parent.table] = yes

  for candidate in tables when candidate._id isnt table._id and candidate.table not of used
    return candidate

  table: ''

pickField = (table) ->
  used = {}
  for parent in table.parents
    used[parent.id] = yes

  for field in table.fields when field.name isnt table.id and field.name not of used
    return field

  name: ''

addParent = (table) ->
  myParent = pickTable table
  myField = pickField table

  newParent =
    _id: makeId()
    _table: table
    name: myParent.table
    id: myField.name
    table: myParent.table

  parentsById[newParent._id] = newParent
  table.parents.push newParent

  newParent

loadTables = (newTables) ->
  newTablesById = {}
  newFieldsById = {}
  newParentsById = {}

  for table in newTables
    table._id = makeId()

    for field in table.fields
      field._id = makeId()
      field._table = table

      newFieldsById[field._id] = field

    for parent in table.parents
      parent._id = makeId()
      parent._table = table

      newParentsById[parent._id] = parent

    newTablesById[table._id] = table

  tables = newTables
  tablesById = newTablesById
  fieldsById = newFieldsById
  parentsById = newParentsById

module.exports = Reflux.createStore
  init: ->
    @listenToMany actions

  getInitialState: ->
    tables

  onLoadConfig: (config) ->
    loadTables config.tables or []

    @trigger tables

  onAddTable: ->
    addTable()

    @trigger tables

  onUpdateName: (tableId, table) ->
    if tableId of tablesById
      me = tablesById[tableId]

      for other in tables
        for parent in other.parents when parent.table is me.table
          parent.table = table

      me.table = table

    @trigger tables

  onUpdateId: (tableId, id) ->
    if tableId of tablesById
      tablesById[tableId].id = id

    @trigger tables

  onAddField: (tableId) ->
    if tableId of tablesById
      addField tablesById[tableId]

    @trigger tables

  onAddParent: (tableId) ->
    if tableId of tablesById
      addParent tablesById[tableId]

    @trigger tables

  onUpdateFieldName: (fieldId, name) ->
    if fieldId of fieldsById
      field = fieldsById[fieldId]

      for parent in field._table.parents when parent.id is field.name
        parent.id = name

      field.name = name

    @trigger tables

  onUpdateFieldType: (fieldId, type) ->
    if fieldId of fieldsById
      fieldsById[fieldId].type = type

    @trigger tables

  onUpdateParentName: (parentId, name) ->
    if parentId of parentsById
      parentsById[parentId].name = name

    @trigger tables

  onUpdateParentId: (parentId, id) ->
    if parentId of parentsById
      parentsById[parentId].id = id

    @trigger tables

  onUpdateParentTable: (parentId, table) ->
    if parentId of parentsById
      parentsById[parentId].table = table

    @trigger tables
