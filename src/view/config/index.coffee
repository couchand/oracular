# config view

React = require 'react'

{
  div, h1, h2
  ul, li, a
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
        a
          name: "configuration"
          href: "#configuration"
          "Configuration"

      ul {},
        li {},
          a
            href: "#tables"
            "Tables"
          ul {},
            @state.config.tables.map (t) ->
              li key: t.key,
                a
                  href: "#table-#{t.table.toLowerCase()}"
                  t.table
        li {},
          a
            href: "#specs"
            "Specs"
          ul {},
            @state.config.specs.map (s) ->
              li key: s.key,
                a
                  href: "#spec-#{s.name.toLowerCase()}"
                  s.name

      h2 {},
        a
          name: "tables"
          href: "#tables"
          "Tables"
      @state.config.tables.map table

      h2 {},
        a
          name: "specs"
          href: "#specs"
          "Specs"
      @state.config.specs.map spec
