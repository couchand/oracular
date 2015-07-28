# raw config view, for debugging/education

React = require 'react'
Reflux = require 'reflux'

{
  div, h1, a, code, pre
} = React.DOM

cleanObjects = require '../clean-objects'
elideDefaults = require '../elide-defaults'
tableStore = require '../table-store'
specStore = require '../spec-store'

module.exports = React.createClass

  name: 'config.raw'

  mixins: [
    Reflux.connect tableStore, 'tables'
    Reflux.connect specStore, 'specs'
  ]

  render: ->
    config = elideDefaults
      tables: cleanObjects @state.tables
      specs: cleanObjects @state.specs

    serialized = try
      JSON.stringify config, null, 2
    catch ex
      console.error "error serializing config:", ex
      ""

    div
      className: "raw"

      h1 {},
        a
          name: "config"
          href: "#config"
          "Raw configuration file"

      pre {}, code {}, serialized
