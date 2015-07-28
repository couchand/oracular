# spec expression editor

React = require 'react'

{
  h2, a, small, div, input
} = React.DOM

{
  ESCAPE_KEY, ENTER_KEY, TAB_KEY
} = require '../util/keys'

{updateSpec} = require '../../spec-actions'

module.exports = React.createClass

  name: 'config.spec.expression.editor'

  propTypes:
    spec: React.PropTypes.object.isRequired

  getInitialState: ->
    editing: no

  startEditing: (e) ->
    @setState editing: yes, source: @props.spec.spec
    e?.preventDefault()

  save: (e) ->
    updateSpec @props.spec._id, @state.source
    @setState editing: no, source: undefined
    e?.preventDefault()

  cancel: ->
    @setState editing: no, source: undefined

  componentWillReceiveProps: (newProps) ->
    return unless @state.editing
    @cancel()

  update: (target: {value: source}) ->
    @setState {source}

  handleKeyDown: ({which}) ->
    switch which
      when ESCAPE_KEY then @cancel()
      when TAB_KEY then @save()
      when ENTER_KEY then @save()

  render: ->
    div
      clasName: "spec-expression"

      if @state.editing
        [
          input
            className: "expression"
            type: "text"
            value: @state.source
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
          @props.spec.spec

          a
            key: "edit-link"
            className: "edit-link"
            href: "#spec-#{@props.spec.name}"
            onClick: @startEditing
            "edit"
        ]
