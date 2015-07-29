# application initialization

React = require 'react'

app = React.createFactory require './view/app'

configure = require './config'

loadTables = require './table-loader'
loadSpecs = require './spec-loader'

tableActions = require './table-actions'
specActions = require './spec-actions'

window.render = (el, initialConfig) ->
  React.render app(), el

  tableresults = loadTables initialConfig.tables
  specresults = loadSpecs tableresults.tables, initialConfig.specs

  if tableresults.errors?.length
    console.error err.toString(), err.config for err in tableresults.errors
  if specresults.errors?.length
    console.error err.toString(), err.config for err in specresults.errors

  config = configure
    tables: tableresults.tables
    specs: specresults.specs

  tableActions.loadConfig config
  specActions.loadConfig config
