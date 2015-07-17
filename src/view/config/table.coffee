# table element

React = require 'react'

{
  div, h2
  table, thead, tbody
  tr, th, a
} = React.DOM

parent = React.createFactory require './parent'
field = React.createFactory require './field'

module.exports = React.createClass

  name: 'config.table'

  propTypes:
    table: React.PropTypes.string.isRequired
    parents: React.PropTypes.array.isRequired
    fields: React.PropTypes.array.isRequired

  render: ->
    div
      className: "table"

      h2
        className: "name"
        a
          name: @props.table
          href: "##{@props.table}"
          @props.table

      table
        className: "parents"
        tbody {}, @props.parents.map parent

      table
        className: "fields"
        tbody {}, @props.fields.map field
