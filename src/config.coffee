# master configuration object

class Config
  constructor: (@tables, @specs) ->

module.exports = ({tables, specs}) ->
  new Config tables, specs
