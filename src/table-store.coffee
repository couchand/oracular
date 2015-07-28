# table store

Reflux = require 'reflux'

actions = require './table-actions'

idsIssued = 0
makeId = ->
  newId = idsIssued
  idsIssued += 1
  newId

tables = []
tablesById = {}
fieldsById = {}
parentsById = {}

addTable = ->
  newTable =
    _id: makeId()
    name: 'NewTable'
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
    name: ''
    type: 'string'

  fieldsById[newField._id] = newField
  table.fields.push newField

  newField

pickTable = (table) ->
  used = {}
  for parent in table.parents
    used[parent.table] = yes

  for candidate in tables when candidate._id isnt table._id and candidate.name not of used
    return candidate

  name: ''

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
    name: myParent.name
    id: myField.name
    table: myParent.name

  parentsById[newParent._id] = newParent
  table.parents.push newParent

  newParent

module.exports = Reflux.createStore
  init: ->
    @listenToMany actions

  getInitialState: ->
    tables

  onAddTable: ->
    addTable()

    @trigger tables

  onUpdateName: (tableId, name) ->
    if tableId of tablesById
      tablesById[tableId].name = name

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
      fieldsById[fieldId].name = name

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
