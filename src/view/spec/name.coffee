# spec name header

React = require 'react'

{
  h2, a, small, div, input
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY, TAB_KEY
} = require '../util/keys'

{updateName} = require '../../spec-actions'

module.exports = React.createClass

  name: 'config.spec.header'

  propTypes:
    spec: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: (e) ->
    @setState editing: yes, name: @props.spec.name
    e?.preventDefault()

  save: (e) ->
    updateName @props.spec._id, @state.name
    @setState editing: no, name: undefined
    e?.preventDefault()

  cancel: ->
    @setState editing: no, name: undefined

  componentWillReceiveProps: (newProps) ->
    return unless @state.editing
    @cancel()

  update: (target: {value: name}) ->
    @setState {name}

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when TAB_KEY then @save()
      when ENTER_KEY then @save()

  render: ->
    div
      clasName: "spec-header"

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
            href: "#spec-#{@props.spec.name}"
            onClick: @save
            "save"
        ]

      else
        [
          h2
            className: "name"
            key: "header"
            a
              name: "spec-#{@props.spec.name}"
              href: "#spec-#{@props.spec.name}"
              @props.spec.name

          a
            key: "edit-link"
            className: "edit-link"
            href: "#spec-#{@props.spec.name}"
            onClick: @startEditing
            "edit"
        ]
