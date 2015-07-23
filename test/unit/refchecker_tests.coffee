# refcheck tests

{chai, should} = require '../helper'

Node = require '../../src/spec/ast'
RefChecker = require '../../src/spec/refchecker'

number = (n) -> new Node.NumberLiteral n
string = (s) -> new Node.StringLiteral s
boolean = (b) -> new Node.BoolLiteral b
reference = (r) -> new Node.Reference r

nullNode = new Node.NullLiteral()

describe "RefChecker", ->
  describe "references", ->
    it "expects root to be in join tables", ->
      ref = reference ['Foobar', 'Baz']

      checker = new RefChecker
        tables: [
          { table: 'Other', fields: [ name: 'Id', type: 'string'] }
          { table: 'Tables', fields: [ name: 'Id', type: 'string'] }
        ]

      (-> ref.walkPreorder ['Other', 'Tables'], checker).should.throw /join/

    it "checks reference root", ->
      ref = reference ['Foobar', 'Baz']

      checker = new RefChecker
        tables: [
          { table: 'Foobar', id: 'Baz', fields: [ name: 'Baz', type: 'string'] }
        ]

      checked = ref.walkPreorder ['Foobar'], checker
      should.exist checked
      checked.should.have.length 1
        .and.contain.all 'Foobar'

  describe "function calls", ->
    it "checks spec references", ->
      call = new Node.FunctionCall reference(['isBaz']), [reference ['Foobar']]

      checker = new RefChecker
        tables: [
          { table: 'Foobar', fields: [ name: 'Id', type: 'string' ] }
        ]
        specs: [
          { name: 'isBaz', table: 'Foobar', spec: 'Foobar.Id != null' }
        ]

      checked = call.walkPreorder ['Foobar'], checker
      should.exist checked
      checked.should.have.length 1
        .and.contain.all 'Foobar'

    it "expects spec to exist", ->
      call = new Node.FunctionCall reference(['isBaz']), [reference ['Foobar']]

      checker = new RefChecker
        tables: [
          { table: 'Foobar', fields: [ name: 'Id', type: 'string' ] }
        ]
        specs: []

      (-> call.walkPreorder ['Foobar'], checker).should.throw /reference/

    it "expects join table to exist", ->
      fingerlingPotatoes = new Node.BinaryOperation reference(['Potato', 'Type']), '=', string 'Fingerling'
      call = new Node.FunctionCall reference(['ANY']), [fingerlingPotatoes]

      checker = new RefChecker
        tables: [
          { table: 'Foobar', fields: [ name: 'Id', type: 'string' ] }
        ]

      (-> call.walkPreorder ['Foobar'], checker).should.throw /reference/

    it "checks join table", ->
      fingerlingPotatoes = new Node.BinaryOperation reference(['Potato', 'Type']), '=', string 'Fingerling'
      call = new Node.FunctionCall reference(['ANY']), [reference(['Potato']), fingerlingPotatoes]

      id = name: 'Id', type: 'string'
      type = name: 'Type', type: 'string'
      foobar = name: 'FoobarId', type: 'string'
      foobarRelationship =  name: 'Foobar', table: 'Foobar', id: 'FoobarId'

      checker = new RefChecker
        tables: [
          { table: 'Foobar', fields: [ id ] }
          { table: 'Potato', fields: [ id, type, foobar ], parents: [foobarRelationship] }
        ]

      checked = call.walkPreorder ['Foobar'], checker
      should.exist checked
      checked.should.have.length 2
        .and.contain.all 'Foobar', 'Potato'
