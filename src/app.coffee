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
    initial = @props.initialConfig or tables: [], specs: []
    config = JSON.stringify initial, null, 2

    {
      config
      parsed: initial
    }

  updateConfig: (config) ->
    @parse config

  parse: (config) ->
    config ?= @state.config

    try
      parsed = JSON.parse config
    catch e
      return @setState {config}

    @setState {parsed, config}

  render: ->
    tableresults = loadTables @state.parsed.tables
    specresults = loadSpecs tableresults.tables, @state.parsed.specs

    if tableresults.errors?.length
      console.error err.toString(), err.config for err in tableresults.errors
    if specresults.errors?.length
      console.error err.toString(), err.config for err in specresults.errors

    configView
      config: configure
        tables: tableresults.tables
        specs: specresults.specs
      configSource: @state.config
      updateConfig: @updateConfig
