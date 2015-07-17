# client-side render

React = require 'react'

application = React.createFactory require './app'

window.render = (el, initialConfig) ->
  view = application {initialConfig}
  React.render view, el
