# parents table

React = require 'react'
Reflux = require 'reflux'

{
  div, h3, a
  table, thead, tbody
  tr, th
} = React.DOM

parentRow = React.createFactory require './parent'

tableStore = require '../../table-store'
{addParent} = require '../../table-actions'

module.exports = React.createClass

  name: 'config.table.parents'

  mixins: [Reflux.connect tableStore, 'tables']

  propTypes:
    table: React.PropTypes.object.isRequired

  addParent: ->
    addParent @props.table._id

  canAddParent: ->
    minCount = 1 + @props.table.parents.length

    hasField = @props.table.fields.length > minCount
    hasTable = @state.tables.length > minCount

    hasField and hasTable

  render: ->
    div
      className: "parents"

      h3 {}, "Parents"

      table {},
        thead {},
          tr {},
            th {}, "Name"
            th {}, "Id"
            th {}, "Table"
            th {}

        tbody {},
          for parent in @props.table.parents
            parentRow
              key: parent._id
              table: @props.table
              parent: parent

      if @canAddParent()
        a
          href: "#table-#{@props.table.table}"
          onClick: @addParent
          "add parent"
