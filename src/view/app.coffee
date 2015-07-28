# application view

React = require 'react'

{
  div
} = React.DOM

tableList = React.createFactory require './tables'
specList = React.createFactory require './specs'
rawConfig = React.createFactory require './raw'

module.exports = React.createClass

  name: "config"

  render: ->
    div
      className: "oracular config"

      tableList()
      specList()
      rawConfig()
