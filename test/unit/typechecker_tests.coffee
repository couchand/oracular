# type check tests

{chai, should} = require '../helper'

Node = require '../../src/spec/ast'
{SpecType} = require '../../src/spec/types'
TypeChecker = require '../../src/spec/typechecker'

number = (n) -> new Node.NumberLiteral n
string = (s) -> new Node.StringLiteral s
boolean = (b) -> new Node.BoolLiteral b

nullNode = new Node.NullLiteral()

describe "TypeChecker", ->
  describe "null literal", ->
    it "is an any", ->
      checked = nullNode.walk new TypeChecker()

      checked.should.have.property 'type', SpecType.Any

  describe "boolean literal", ->
    it "is a boolean", ->
      booleanNode = boolean no

      checked = booleanNode.walk new TypeChecker()

      checked.should.have.property 'type', SpecType.Boolean

  describe "number literal", ->
    it "is a number", ->
      numberNode = number 42

      checked = numberNode.walk new TypeChecker()

      checked.should.have.property 'type', SpecType.Number

  describe "string literal", ->
    it "is a string", ->
      stringNode = string "foobar"

      checked = stringNode.walk new TypeChecker()

      checked.should.have.property 'type', SpecType.String

  checkOperation = (op, left, right, expected) ->
    binaryNode = new Node.BinaryOperation left, op, right

    checked = binaryNode.walk new TypeChecker()

    checked.should.have.property 'type', expected

  describe "binary arithmetic", ->
    it "works on numbers", ->
      checkOperation '+', number(1), number(2), SpecType.Number
      checkOperation '-', number(1), number(2), SpecType.Number
      checkOperation '*', number(1), number(2), SpecType.Number
      checkOperation '/', number(1), number(2), SpecType.Number

    it "errors on strings", ->
      (-> checkOperation '+', number(42), string("bar")).should.throw /invalid/
      (-> checkOperation '+', string("foo"), number(42)).should.throw /invalid/
      (-> checkOperation '-', number(42), string("bar")).should.throw /invalid/
      (-> checkOperation '-', string("foo"), number(42)).should.throw /invalid/
      (-> checkOperation '*', number(42), string("bar")).should.throw /invalid/
      (-> checkOperation '*', string("foo"), number(42)).should.throw /invalid/
      (-> checkOperation '/', number(42), string("bar")).should.throw /invalid/
      (-> checkOperation '/', string("foo"), number(42)).should.throw /invalid/

    it "errors on null", ->
      (-> checkOperation '+', number("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '+', nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '-', number("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '-', nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '*', number("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '*', nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '/', number("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '/', nullNode, string("foo")).should.throw /invalid/

    it "errors on booleans", ->
      (-> checkOperation '+', number(42), boolean(yes)).should.throw /invalid/
      (-> checkOperation '+', boolean(yes), number(42)).should.throw /invalid/
      (-> checkOperation '-', number(42), boolean(yes)).should.throw /invalid/
      (-> checkOperation '-', boolean(yes), number(42)).should.throw /invalid/
      (-> checkOperation '*', number(42), boolean(yes)).should.throw /invalid/
      (-> checkOperation '*', boolean(yes), number(42)).should.throw /invalid/
      (-> checkOperation '/', number(42), boolean(yes)).should.throw /invalid/
      (-> checkOperation '/', boolean(yes), number(42)).should.throw /invalid/

  describe "logical comparisons", ->
    it "works on numbers", ->
      checkOperation '=',  number(1), number(2), SpecType.Boolean
      checkOperation '!=', number(1), number(2), SpecType.Boolean
      checkOperation '<',  number(1), number(2), SpecType.Boolean
      checkOperation '<=', number(1), number(2), SpecType.Boolean
      checkOperation '>',  number(1), number(2), SpecType.Boolean
      checkOperation '>=', number(1), number(2), SpecType.Boolean

    it "works for strings", ->
      checkOperation '=',  string("foo"), string("bar"), SpecType.Boolean
      checkOperation '!=', string("foo"), string("bar"), SpecType.Boolean
      checkOperation '<',  string("foo"), string("bar"), SpecType.Boolean
      checkOperation '<=', string("foo"), string("bar"), SpecType.Boolean
      checkOperation '>',  string("foo"), string("bar"), SpecType.Boolean
      checkOperation '>=', string("foo"), string("bar"), SpecType.Boolean

    it "works on equality for booleans", ->
      checkOperation '=',  boolean(no), boolean(yes), SpecType.Boolean
      checkOperation '!=', boolean(no), boolean(yes), SpecType.Boolean

    it "errors on inequality for booleans", ->
      (-> checkOperation '<',  boolean(no), boolean(yes)).should.throw /invalid/
      (-> checkOperation '<=',  boolean(no), boolean(yes)).should.throw /invalid/
      (-> checkOperation '>',  boolean(no), boolean(yes)).should.throw /invalid/
      (-> checkOperation '>=',  boolean(no), boolean(yes)).should.throw /invalid/

    it "errors for mixed types", ->
      (-> checkOperation '=',  number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '=',  string("foo"), number(1)).should.throw /incompatible/
      (-> checkOperation '!=', number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '!=', string("foo"), number(1)).should.throw /incompatible/
      (-> checkOperation '<',  number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '<',  string("foo"), number(1)).should.throw /incompatible/
      (-> checkOperation '<=', number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '<=', string("foo"), number(1)).should.throw /incompatible/
      (-> checkOperation '>',  number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '>',  string("foo"), number(1)).should.throw /incompatible/
      (-> checkOperation '>=', number(1), string("foo")).should.throw /incompatible/
      (-> checkOperation '>=', string("foo"), number(1)).should.throw /incompatible/

    it "allows null values on equality", ->
      checkOperation '=',  number(1), nullNode, SpecType.Boolean
      checkOperation '=',  nullNode, number(1), SpecType.Boolean
      checkOperation '!=', number(1), nullNode, SpecType.Boolean
      checkOperation '!=', nullNode, number(1), SpecType.Boolean
      checkOperation '=',  string("foo"), nullNode, SpecType.Boolean
      checkOperation '=',  nullNode, string("foo"), SpecType.Boolean
      checkOperation '!=', string("foo"), nullNode, SpecType.Boolean
      checkOperation '!=', nullNode, string("foo"), SpecType.Boolean
      checkOperation '=',  boolean(no), nullNode, SpecType.Boolean
      checkOperation '=',  nullNode, boolean(no), SpecType.Boolean
      checkOperation '!=', boolean(no), nullNode, SpecType.Boolean
      checkOperation '!=', nullNode, boolean(no), SpecType.Boolean

    it "errors on null values for inequality", ->
      (-> checkOperation '<',  number(1), nullNode).should.throw /invalid/
      (-> checkOperation '<=', number(1), nullNode).should.throw /invalid/
      (-> checkOperation '>',  number(1), nullNode).should.throw /invalid/
      (-> checkOperation '>=', number(1), nullNode).should.throw /invalid/
      (-> checkOperation '<',  nullNode, number(1)).should.throw /invalid/
      (-> checkOperation '<=', nullNode, number(1)).should.throw /invalid/
      (-> checkOperation '>',  nullNode, number(1)).should.throw /invalid/
      (-> checkOperation '>=', nullNode, number(1)).should.throw /invalid/
      (-> checkOperation '<',  string("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '<=', string("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '>',  string("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '>=', string("foo"), nullNode).should.throw /invalid/
      (-> checkOperation '<',  nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '<=', nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '>',  nullNode, string("foo")).should.throw /invalid/
      (-> checkOperation '>=', nullNode, string("foo")).should.throw /invalid/