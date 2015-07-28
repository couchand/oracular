# one parent row

React = require 'react'
Reflux = require 'reflux'

{
  tr, td
  a, input
  select, option
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY
} = require '../util/keys'

tableStore = require '../../table-store'

{updateParentName, updateParentId, updateParentTable} = require '../../table-actions'

module.exports = React.createClass

  name: 'config.table.parent.row'

  mixins: [Reflux.connect tableStore, 'tables']

  propTypes:
    table: React.PropTypes.object.isRequired
    parent: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: ->
    @setState
      editing: yes
      name: @props.parent.name
      id: @props.parent.id
      table: @props.parent.table

  handleNameChange: (target: {value: name}) ->
    @setState {name}

  handleIdChange: (target: {value: id}) ->
    @setState {id}

  handleTableChange: (target: {value: table}) ->
    @setState {table}

  save: ->
    updateParentName @props.parent._id, @state.name
    updateParentId @props.parent._id, @state.id
    updateParentTable @props.parent._id, @state.table

    @cancel()

  cancel: ->
    @setState
      editing: no
      name: undefined
      id: undefined
      table: undefined

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when ENTER_KEY then @save()

  fieldIsValidForParent: (field, usedFields) ->
    field.name isnt @props.table.id and (field.name not of usedFields or field.name is @state.id)

  tableIsValidForParent: (table, usedTables) ->
    table._id isnt @props.table._id and (table.name not of usedTables or table.name is @state.table)

  render: ->
    usedFields = {}
    usedTables = {}

    for parent in @props.table.parents
      usedTables[parent.table] = yes
      usedFields[parent.id] = yes

    tr
      className: "parent"

      td {},
        if @state.editing
          input
            type: "text"
            value: @state.name
            onChange: @handleNameChange
            onKeyDown: @handleKeyDown

        else
          @props.parent.name

      td {},
        if @state.editing
          select
            value: @state.id
            value: @state.id
            onChange: @handleIdChange

            for field in @props.table.fields when @fieldIsValidForParent field, usedFields
              option
                key: field._id
                value: field.name
                field.name

        else
          @props.parent.id

      td {},
        if @state.editing
          select
            value: @state.table
            onChange: @handleTableChange

            for table in @state.tables when @tableIsValidForParent table, usedTables
              option
                key: table._id
                value: table.name
                table.name

        else
          @props.parent.table

      td {},
        if @state.editing
          a
            href: "#table-#{@props.table.name}"
            onClick: @save
            "save"

        else
          a
            href: "#table-#{@props.table.name}"
            onClick: @startEditing
            "edit"
