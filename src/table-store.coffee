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

module.exports = Reflux.createStore
  init: ->
    @listenToMany actions

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

  onUpdateFieldName: (fieldId, name) ->
    if fieldId of fieldsById
      fieldsById[fieldId].name = name

    @trigger tables

  onUpdateFieldType: (fieldId, type) ->
    if fieldId of fieldsById
      fieldsById[fieldId].type = type

    @trigger tables
