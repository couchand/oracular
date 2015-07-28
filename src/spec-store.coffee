# spec store

Reflux = require 'reflux'

makeId = require './make-id'
actions = require './spec-actions'

specs = []
specsById = {}

nameSpec = (prefix) ->
  count = 0

  for spec in specs when spec.name[...prefix.length] is prefix
    count += 1

  if count is 0
    prefix
  else
    specNames = specs.map (s) -> s.name
    while (suggestion = prefix + (1 + count)) in specNames
      count += 1
    suggestion

addSpec = (table) ->
  newSpec =
    _id: makeId()
    name: nameSpec 'NewSpec'
    table: table
    spec: 'true'

  specsById[newSpec._id] = newSpec
  specs.push newSpec

  newSpec

module.exports = Reflux.createStore
  init: ->
    @listenToMany actions

  getInitialState: ->
    specs

  onAddSpec: (table) ->
    addSpec table

    @trigger specs

  onUpdateName: (specId, name) ->
    if specId of specsById
      specsById[specId].name = name

    @trigger specs

  onUpdateTable: (specId, table) ->
    if specId of specsById
      specsById[specId].table = table

    @trigger specs

  onUpdateSpec: (specId, spec) ->
    if specId of specsById
      specsById[specId].spec = spec

    @trigger specs
