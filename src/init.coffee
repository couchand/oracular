# application initialization

React = require 'react'

tableList = React.createFactory require './view/tables'

tableStore = require './table-store'

window.render = (el, initialConfig) ->
  view = tableList()
  React.render view, el
