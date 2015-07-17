# field element

React = require 'react'

{
  tr, td
} = React.DOM

module.exports = React.createClass

  name: 'config.field'

  propTypes:
    name: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired

  render: ->
    tr
      className: "field"

      td
        className: "name"
        @props.name

      td
        className: "type"
        @props.type
