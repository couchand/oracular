# sql view

React = require 'react'
Reflux = require 'reflux'

{
  div, h4, code, pre
} = React.DOM

Sqlizer = require '../../spec/sqlizer'

tableStore = require '../../table-store'
specStore = require '../../spec-store'

module.exports = React.createClass

  name: 'config.spec.sql'

  mixins: [
    Reflux.connect tableStore, 'tables'
    Reflux.connect specStore, 'specs'
  ]

  propTypes:
    spec: React.PropTypes.object.isRequired

  render: ->
    config =
      tables: @state.tables
      specs: @state.specs

    sql = try
      builder = new Sqlizer config
      builder.serialize @props.spec, @props.spec.spec
    catch ex
      ex.message

    div
      className: "sql"

      h4 {}, "SQL"

      pre {}, code {}, sql
