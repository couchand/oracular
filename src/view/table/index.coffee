# table view

React = require 'react'

{
  div, a
} = React.DOM

name = React.createFactory require './name'
fields = React.createFactory require './fields'
parents = React.createFactory require './parents'

{addSpec} = require '../../spec-actions'

module.exports = React.createClass

  name: 'config.table'

  propTypes:
    table: React.PropTypes.object.isRequired

  addSpec: ->
    addSpec @props.table.table

  render: ->
    {table} = @props

    div
      className: "table"

      name {table}

      a
        href: "#table-#{table.table}"
        onClick: @addSpec
        "add spec"

      parents {table}
      fields {table}
