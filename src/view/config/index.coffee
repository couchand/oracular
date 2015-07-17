# config view

React = require 'react'

{
  div, h1, h2
} = React.DOM

table = React.createFactory require './table'
spec = React.createFactory require './spec'

module.exports = React.createClass

  name: "config"

  propTypes:
    config: React.PropTypes.object.isRequired

  getInitialState: ->
    config: @props.config

  updateConfig: (config) ->
    @setState {config}

  render: ->
    div
      className: "config"

      h1
        className: "title"
        "Configuration"

      h2 {}, "Tables"
      @state.config.tables.map table

      h2 {}, "Specs"
      @state.config.specs.map spec
