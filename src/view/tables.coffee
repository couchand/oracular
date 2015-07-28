# tables list

React = require 'react'
Reflux = require 'reflux'

{
  div, a
} = React.DOM

tableStore = require '../table-store'
{addTable} = require '../table-actions'

tableView = React.createFactory require './table'

module.exports = React.createClass

  name: 'config.tables.list'

  getInitialState: ->
    tables: []

  mixins: [Reflux.connect tableStore, 'tables']

  addTable: (e) ->
    addTable()
    e.preventDefault()

  render: ->
    div
      className: "tables"

      for table in @state.tables
        tableView {table, key: table._id}

      a
        href: '#'
        className: 'new-table-link'
        onClick: @addTable
        'add table'
