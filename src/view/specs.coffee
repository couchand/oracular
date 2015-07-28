# specs list

React = require 'react'
Reflux = require 'reflux'

{
  div, h1, a
} = React.DOM

specStore = require '../spec-store'

specView = React.createFactory require './spec'

module.exports = React.createClass

  name: 'config.specs.list'

  mixins: [Reflux.connect specStore, 'specs']

  render: ->
    div
      className: "specs"

      h1 {},
        a
          name: 'specs'
          href: '#specs'
          'Specs'

      for spec in @state.specs
        specView
          key: spec._id
          spec: spec
