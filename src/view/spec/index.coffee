# spec view

React = require 'react'

{
  div
} = React.DOM

name = React.createFactory require './name'
table = React.createFactory require './table'
expressionEditor = React.createFactory require './expression'
sqlViewer = React.createFactory require './sql'

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
      sqlViewer {spec}
