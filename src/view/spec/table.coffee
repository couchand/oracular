# spec table select

React = require 'react'
Reflux = require 'reflux'

{
  div, a
  select, option
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY
} = require '../util/keys'

tableStore = require '../../table-store'

{updateTable} = require '../../spec-actions'

module.exports = React.createClass

  name: 'config.spec.table'

  mixins: [Reflux.connect tableStore, 'tables']

  propTypes:
    spec: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: ->
    @setState
      editing: yes
      table: @props.spec.table

  handleTableChange: (target: {value: table}) ->
    @setState {table}

  componentWillReceiveProps: (newProps) ->
    return unless @state.editing
    @cancel()

  save: ->
    updateTable @props.spec._id, @state.table

    @cancel()

  cancel: ->
    @setState
      editing: no
      table: undefined

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when ENTER_KEY then @save()

  render: ->
    div
      className: "spec-table"

      if @state.editing
        [
          select
            key: 'select'
            value: @state.table
            onChange: @handleTableChange

            for table in @state.tables
              option
                key: table._id
                value: table.table
                table.table

          a
            key: 'a'
            className: 'save-link'
            href: "#spec-#{@props.spec.name}"
            onClick: @save
            "save"
        ]

      else
        [
          @props.spec.table

          a
            key: 'a'
            className: 'edit-link'
            href: "#spec-#{@props.spec.name}"
            onClick: @startEditing
            "edit"
        ]
