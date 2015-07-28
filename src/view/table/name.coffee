# table name header

React = require 'react'

{
  h2, a, small, div, input
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY, TAB_KEY
} = require '../util/keys'

{updateName} = require '../../table-actions'

module.exports = React.createClass

  name: 'config.table.header'

  propTypes:
    table: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: (e) ->
    @setState editing: yes, name: @props.table.name
    e?.preventDefault()

  save: (e) ->
    updateName @props.table._id, @state.name
    @setState editing: no, name: undefined
    e?.preventDefault()

  cancel: ->
    @setState editing: no, name: undefined

  update: (target: {value: name}) ->
    @setState {name}

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when TAB_KEY then @save()
      when ENTER_KEY then @save()

  render: ->
    div
      clasName: "table-header"

      if @state.editing
        [
          input
            className: "name"
            type: "text"
            value: @state.name
            onChange: @update
            onKeyDown: @handleKeyDown
            key: "input"

          a
            key: "a"
            className: "save-link"
            href: "#table-#{@props.table.name}"
            onClick: @save
            "save"
        ]

      else
        [
          h2
            className: "name"
            key: "header"
            a
              name: "table-#{@props.table.name}"
              href: "#table-#{@props.table.name}"
              @props.table.name

          a
            key: "edit-link"
            className: "edit-link"
            href: "#table-#{@props.table.name}"
            onClick: @startEditing
            "edit"
        ]
