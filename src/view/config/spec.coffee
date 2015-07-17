# spec view

React = require 'react'

{
  div, h4, small, a
  ul, li, textarea
} = React.DOM

Node = require '../../spec/ast'

renderNode = (node) ->
  switch on
    when node instanceof Node.Reference
      div className: 'reference', node.toString()
    when node instanceof Node.StringLiteral
      div className: 'string', node.value
    when node instanceof Node.NumberLiteral
      div className: 'number', node.toString()
    when node instanceof Node.BoolLiteral
      div className: 'bool', node.toString()
    when node instanceof Node.NullLiteral
      div className: 'null', node.toString()

    when node instanceof Node.BinaryOperation
      div className: 'binary',
        node.operator
        ul {},
          li {}, renderNode node.left
          li {}, renderNode node.right

    when node instanceof Node.AndSpecification
      div className: 'conjunction',
        "AND"
        ul {},
          li {}, renderNode node.left
          li {}, renderNode node.right

    when node instanceof Node.OrSpecification
      div className: 'disjunction',
        "OR"
        ul {},
          li {}, renderNode node.left
          li {}, renderNode node.right

    when node instanceof Node.FunctionCall
      div className: 'call',
        renderNode node.function
        ul {},
          for i, param of node.parameters
            li key: i, renderNode param

    else
      div className: 'unknown-node', node.toString()

module.exports = React.createClass
  name: "spec"

  propType: ->
    name: React.PropTypes.string.isRequired
    table: React.PropTypes.string.isRequired
    source: React.PropTypes.string.isRequired
    spec: React.PropTypes.object.isRequired
    updateSpec: React.PropTypes.func

  handleSpecChange: (target: {value: spec}) ->
    @props.updateSpec? spec

  render: ->
    div
      className: "specs"

      h4 {},
        a
          name: "spec-#{@props.name.toLowerCase()}"
          href: "#spec-#{@props.name.toLowerCase()}"
          @props.name
        small {},
          " on "
          a
            href: "#table-#{@props.table.toLowerCase()}"
            @props.table

      textarea
        className: 'expression-edit'
        value: @props.source
        onChange: @handleSpecChange
        rows: 5
        cols: 60

      div
        className: 'expression'
        ul {}, li {},
          renderNode @props.spec
