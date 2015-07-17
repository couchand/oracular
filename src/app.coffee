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
    config: JSON.stringify @props.initialConfig or tables: [], specs: [], null, 2

  updateConfig: (config) ->
    @setState {config}

  shouldComponentUpdate: ->
    try
      JSON.parse @state.config
      return yes
    catch e
      return no

  render: ->
    config = JSON.parse @state.config
    tableresults = loadTables config.tables
    specresults = loadSpecs tableresults.tables, config.specs

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
