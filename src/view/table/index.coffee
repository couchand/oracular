# table view

React = require 'react'

{
  div
} = React.DOM

name = React.createFactory require './name'
fields = React.createFactory require './fields'

module.exports = React.createClass

  name: 'config.table'

  propTypes:
    table: React.PropTypes.object.isRequired

  render: ->
    {table} = @props

    div
      className: "table"

      name {table}
      fields {table}
