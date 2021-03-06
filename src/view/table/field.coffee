# one field row

React = require 'react'

{
  tr, td
  a, input
  select, option
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY
} = require '../util/keys'

{updateId, updateFieldName, updateFieldType} = require '../../table-actions'
FIELD_TYPES = require '../../field-types'

module.exports = React.createClass

  name: 'config.table.field.row'

  propTypes:
    table: React.PropTypes.object.isRequired
    field: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: ->
    @setState
      editing: yes
      name: @props.field.name
      type: @props.field.type

  handleNameChange: (target: {value: name}) ->
    @setState {name}

  handleTypeChange: (target: {value: type}) ->
    @setState {type}

  isIdField: ->
    @props.table.id is @props.field.name

  save: ->
    doUpdateTableId = @isIdField()

    updateFieldName @props.field._id, @state.name
    updateFieldType @props.field._id, @state.type

    if doUpdateTableId
      updateId @props.table._id, @state.name

    @cancel()

  cancel: ->
    @setState
      editing: no
      name: undefined
      type: undefined

  componentWillReceiveProps: (newProps) ->
    return unless @state.editing
    @cancel()

  setIdField: ->
    updateId @props.table._id, @props.field.name

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when ENTER_KEY then @save()

  render: ->
    tr
      className: "field"

      td {},
        input
          type: 'radio'
          name: "table-#{@props.table._id}-radio"
          checked: @isIdField()
          onChange: @setIdField

      td {},
        if @state.editing
          input
            type: "text"
            value: @state.name
            onChange: @handleNameChange
            onKeyDown: @handleKeyDown

        else
          @props.field.name

      td {},
        if @state.editing
          select
            value: @state.type
            onChange: @handleTypeChange
            for type in FIELD_TYPES
              option
                key: type
                value: type
                type

        else
          @props.field.type

      td {},
        if @state.editing
          a
            href: "#table-#{@props.table.table}"
            onClick: @save
            "save"

        else
          a
            href: "#table-#{@props.table.table}"
            onClick: @startEditing
            "edit"
