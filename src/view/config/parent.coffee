# parent element

React = require 'react'

{
  tr, td, a
} = React.DOM

module.exports = React.createClass

  name: 'config.parent'

  propTypes:
    name: React.PropTypes.string.isRequired
    table: React.PropTypes.string.isRequired
    id: React.PropTypes.string.isRequired

  render: ->
    tr
      className: "parent"

      td
        className: "name"
        @props.name

      td
        className: "id"
        @props.id

      td
        className: "table"
        a
          href: "#table-#{@props.table.toLowerCase()}"
          @props.table
