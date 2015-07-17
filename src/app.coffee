# application

React = require 'react'

configure = require './config'
configView = React.createFactory require './view/config'

loadTables = require './table-loader'
loadSpecs = require './spec-loader'

window.render = (el, config) ->
  tableresults = loadTables config.tables
  specresults = loadSpecs tableresults.tables, config.specs

  if tableresults.errors?.length
    console.error err.toString(), err.config for err in tableresults.errors
  if specresults.errors?.length
    console.error err.toString(), err.config for err in specresults.errors

  view = configView config: configure
    tables: tableresults.tables
    specs: specresults.specs
    #errors: tableresults.errors.concat specresults.errors

  React.render view, el
