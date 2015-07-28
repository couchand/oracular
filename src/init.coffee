# application initialization

React = require 'react'

app = React.createFactory require './view/app'

window.render = (el, initialConfig) ->
  React.render app(), el
