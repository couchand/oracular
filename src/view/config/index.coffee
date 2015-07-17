# config view

React = require 'react'

{
  div, h1, h2
  ul, li, a
  textarea
} = React.DOM

table = React.createFactory require './table'
spec = React.createFactory require './spec'

module.exports = React.createClass

  name: "config"

  propTypes:
    config: React.PropTypes.object.isRequired
    configSource: React.PropTypes.string.isRequired
    updateConfig: React.PropTypes.func.isRequired

  handleUpdate: (target: {value: config}) ->
    @props.updateConfig config

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
            @props.config.tables.map (t) ->
              li key: t.key,
                a
                  href: "#table-#{t.table.toLowerCase()}"
                  t.table
        li {},
          a
            href: "#specs"
            "Specs"
          ul {},
            @props.config.specs.map (s) ->
              li key: s.key,
                a
                  href: "#spec-#{s.name.toLowerCase()}"
                  s.name

      textarea
        rows: 12
        cols: 80
        value: @props.configSource
        onChange: @handleUpdate

      h2 {},
        a
          name: "tables"
          href: "#tables"
          "Tables"
      @props.config.tables.map table

      h2 {},
        a
          name: "specs"
          href: "#specs"
          "Specs"
      @props.config.specs.map spec
