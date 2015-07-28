# table view

React = require 'react'

{
  div
} = React.DOM

name = React.createFactory require './name'
fields = React.createFactory require './fields'
parents = React.createFactory require './parents'

module.exports = React.createClass

  name: 'config.table'

  propTypes:
    table: React.PropTypes.object.isRequired

  render: ->
    {table} = @props

    div
      className: "table"

      name {table}
      parents {table}
      fields {table}
