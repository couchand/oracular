# spec view

React = require 'react'

{
  div
} = React.DOM

name = React.createFactory require './name'
table = React.createFactory require './table'
expressionEditor = React.createFactory require './expression'

module.exports = React.createClass

  name: 'config.spec'

  propTypes:
    spec: React.PropTypes.object.isRequired

  render: ->
    {spec} = @props

    div
      className: "spec"

      name {spec}
      table {spec}
      expressionEditor {spec}
