# load spec config

parseSpec = require './parse'

Node = require './spec/ast'

BUILTINS = [
  'today'
]

validateReference = (root, tables, node) ->
  return null if node.segments[0].toLowerCase() in BUILTINS

  if root isnt node.segments[0]
    'all top-level references must be from the main table'
  else
    unless node.segments.length > 1
      null
    else if node.segments.length is 2
      foundit = no
      for field in tables[root].fields when field.name is node.segments[1]
        foundit = yes
        break
      if foundit then null else "field '#{node.segments[1]}' not found on '#{root}'"
    else
      foundit = no
      for parent in tables[root].parents when parent.name is node.segments[1]
        # TODO: check further
        foundit = yes
        break
      if foundit then null else "parent '#{node.segments[1]}' not found on '#{root}'"

validateFunctionCall = (root, tables, node) ->
  return "parameters required" unless node.parameters?.length

  newRoot = node.parameters[0].segments[0]

  error = null
  for param in node.parameters
    error = validateExpression newRoot, tables, param
    break if error
  error

validateExpression = (root, tables, node) ->
  switch on
    when node instanceof Node.Reference
      validateReference root, tables, node
    when node instanceof Node.StringLiteral
      null
    when node instanceof Node.NumberLiteral
      null
    when node instanceof Node.BoolLiteral
      null
    when node instanceof Node.NullLiteral
      null
    when node instanceof Node.BinaryOperation
      unless node.operator in Node.OPERATORS
        "operator '#{node.operator}' not known"
      else
        validateExpression(root, tables, node.left) or
          validateExpression root, tables, node.right
    when node instanceof Node.AndSpecification
      validateExpression(root, tables, node.left) or
        validateExpression root, tables, node.right
    when node instanceof Node.OrSpecification
      validateExpression(root, tables, node.left) or
        validateExpression root, tables, node.right
    when node instanceof Node.FunctionCall
      validateFunctionCall root, tables, node

    else 'node type not known'

validateSpec = (tablesByName, specsByName, spec) ->
  root = spec.table
  return "table '#{root}' not found" unless root of tablesByName

  validateExpression root, tablesByName, spec.spec

class Spec
  constructor: (@name, @table, @source, @spec) ->
    @key = 'spec-' + @name

class SpecError
  constructor: (@config, @error) ->

  toString: ->
    "Invalid spec: #{@error}"

module.exports = (tables, config) ->
  loaded = []
  errors = []

  for row in config
    unless row.name and row.table and row.spec
      errors.push new SpecError row, "required fields not found"
      continue

    try
      parsed = parseSpec row.spec
      loaded.push new Spec row.name, row.table, row.spec, parsed
    catch err
      errors.push err

  specs = []

  tablesByName = {}
  tablesByName[table.table] = table for table in tables
  specsByName = {}
  specsByName[spec.name] = spec for spec in loaded

  for spec in loaded
    error = validateSpec tablesByName, specsByName, spec
    if error
      errors.push new SpecError spec, error
      continue

    specs.push spec

  {specs, errors}
