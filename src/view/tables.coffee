# tables list

React = require 'react'
Reflux = require 'reflux'

{
  div, h1, a
} = React.DOM

tableStore = require '../table-store'
{addTable} = require '../table-actions'

tableView = React.createFactory require './table'

module.exports = React.createClass

  name: 'config.tables.list'

  mixins: [Reflux.connect tableStore, 'tables']

  addTable: (e) ->
    addTable()
    e.preventDefault()

  render: ->
    div
      className: "tables"

      h1 {},
        a
          name: 'tables'
          href: '#tables'
          'Tables'

      for table in @state.tables
        tableView {table, key: table._id}

      a
        href: '#tables'
        className: 'new-table-link'
        onClick: @addTable
        'add table'
