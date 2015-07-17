# application

React = require 'react'

configure = require './config'
configView = React.createFactory require './view/config'

loadTables = require './table-loader'
loadSpecs = require './spec-loader'

module.exports = React.createClass
  name: "app"

  propTypes:
    initialConfig: React.PropTypes.object

  getInitialState: ->
    config: @props.initialConfig or tables: [], specs: []

  render: ->
    tableresults = loadTables @state.config.tables
    specresults = loadSpecs tableresults.tables, @state.config.specs

    if tableresults.errors?.length
      console.error err.toString(), err.config for err in tableresults.errors
    if specresults.errors?.length
      console.error err.toString(), err.config for err in specresults.errors

    configView config: configure
      tables: tableresults.tables
      specs: specresults.specs
