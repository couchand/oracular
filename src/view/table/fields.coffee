# fields table

React = require 'react'

{
  div, h3, a
  table, thead, tbody
  tr, th
} = React.DOM

fieldRow = React.createFactory require './field'

{addField} = require '../../table-actions'

module.exports = React.createClass

  name: 'config.table.fields'

  propTypes:
    table: React.PropTypes.object.isRequired

  addField: ->
    addField @props.table._id

  render: ->
    div
      className: "fields"

      h3 {}, "Fields"

      table {},
        thead {},
          tr {},
            th {}, "Id"
            th {}, "Name"
            th {}, "Type"
            th {}

        tbody {},
          for field in @props.table.fields
            fieldRow
              key: field._id
              table: @props.table
              field: field

      a
        href: "#table-#{@props.table.name}"
        onClick: @addField
        "add field"
