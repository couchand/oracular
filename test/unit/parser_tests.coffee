# parser tests

{should} = require '../helper'

Node = require '../../src/spec/ast'
Parser = require '../../src/spec/parser'
TokenType = require '../../src/spec/token'

ArrayLexer = require '../array-lexer'

parse = (input) ->
  new Parser new ArrayLexer input

string = (str) ->
  type: TokenType.String
  value: str
  toString: -> "string: #{str}"

number = (num) ->
  type: TokenType.Number
  value: num
  toString: -> "number: #{num}"

operator = (op) ->
  type: TokenType.Operator
  value: op
  toString: -> "operator: #{op}"

reference = (refs) ->
  type: TokenType.Reference
  value: refs
  toString: -> "reference: #{refs.join '.'}"

openParen =
  type: TokenType.OpenParen
  toString: -> 'openparen'

closeParen =
  type: TokenType.CloseParen
  toString: -> 'closeparen'

comma =
  type: TokenType.Comma
  toString: -> 'comma'

describe 'Parser', ->
  describe '#', ->
    describe 'parse', ->
      it 'is a function', ->
        me = parse []

        me.should.have.property 'parse'
          .that.is.a 'function'

      it 'parses numbers', ->
        me = parse [
          number 42
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.NumberLiteral

      it 'parses strings', ->
        me = parse [
          string 'foobar'
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.StringLiteral

      validateBinaryOperation = (tree, left, op, right) ->
        tree.should.be.an.instanceof Node.BinaryOperation
        tree.should.have.property 'left'
          .that.satisfy left
        tree.should.have.property 'right'
          .that.satisfy right
        tree.should.have.property 'operator', op

      checkBinary = (op) -> ->
        me = parse [
          number 1
          operator op
          number 2
        ]

        tree = me.parse()

        isOne = (v) -> v.should.have.property 'value', 1; yes
        isTwo = (v) -> v.should.have.property 'value', 2; yes

        validateBinaryOperation tree, isOne, op, isTwo

      it 'parses addition', checkBinary '+'
      it 'parses subtraction', checkBinary '-'
      it 'parses multiplication', checkBinary '*'
      it 'parses division', checkBinary '/'

      it 'parses equals', checkBinary '='
      it 'parses not equals', checkBinary '!='
      it 'parses less than', checkBinary '<'
      it 'parses greater than', checkBinary '>'
      it 'parses at most', checkBinary '<='
      it 'parses at least', checkBinary '>='

      it 'parses operators with precedence', ->
        one = number 1
        two = number 2
        three = number 3
        four = number 4

        equals = operator '='
        plus = operator '+'
        times = operator '*'

        left = parse [
          one, equals, two, plus, three, times, four
        ]
        right = parse [
          one, times, two, plus, three, equals, four
        ]

        leftTree = left.parse()
        rightTree = right.parse()

        leftRightSide = (v) ->
          v.should.have.deep.property 'left.value', 2
          v.should.have.property 'operator', '+'
          v.should.have.deep.property 'right.left.value', 3
          v.should.have.deep.property 'right.operator', '*'
          v.should.have.deep.property 'right.right.value', 4
          yes

        isOne = (v) -> v.should.have.property 'value', 1; yes

        validateBinaryOperation leftTree, isOne, '=', leftRightSide

        rightLeftSide = (v) ->
          v.should.have.deep.property 'left.left.value', 1
          v.should.have.deep.property 'left.operator', '*'
          v.should.have.deep.property 'left.right.value', 2
          v.should.have.property 'operator', '+'
          v.should.have.deep.property 'right.value', 3
          yes

        isFour = (v) -> v.should.have.property 'value', 4; yes

        validateBinaryOperation rightTree, rightLeftSide, '=', isFour

      checkNull = (str) ->
        me = parse [
          reference [str]
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.NullLiteral

      it 'parses null literals', ->
        checkNull 'null'
        checkNull 'NULL'
        checkNull 'NuLl'

      checkBool = (str, val) ->
        me = parse [
          reference [str]
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.BoolLiteral
        tree.should.have.property 'value', val

      it 'parses true literals', ->
        checkBool 'true', yes
        checkBool 'TRUE', yes
        checkBool 'tRUe', yes

      it 'parses false literals', ->
        checkBool 'false', no
        checkBool 'FALSE', no
        checkBool 'fAlSe', no

      checkRef = (refs) ->
        me = parse [
          reference [].concat refs
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.Reference
        tree.should.have.property 'segments'
          .that.deep.equals refs

      it 'parses references', ->
        checkRef ['foo']
        checkRef ['foo', 'bar']
        checkRef ['foo', 'bar', 'baz']

      it 'parses references with names like keywords', ->
        checkRef ['truer']
        checkRef ['atrue']
        checkRef ['falsely']
        checkRef ['isfalse']
        checkRef ['nulletta']
        checkRef ['notnull']

      it 'throws on not enough input', ->
        me = parse [
          number 42
          operator '+'
        ]

        (-> me.parse()).should.throw /not enough/i

      it 'throws on too much input', ->
        me = parse [
          number 42
          number 43
        ]

        (-> me.parse()).should.throw /too much/i

      checkConjunction = (str) ->
        me = parse [
          reference ['true']
          operator str
          reference ['true']
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.LogicalConjunction
        tree.should.have.property 'left'
          .that.is.an.instanceof Node.BoolLiteral
        tree.should.have.property 'right'
          .that.is.an.instanceof Node.BoolLiteral

      it 'parses binary conjunction', ->
        checkConjunction 'and'
        checkConjunction 'AND'
        checkConjunction 'aND'

      checkDisjunction = (str) ->
        me = parse [
          reference ['true']
          operator str
          reference ['true']
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.LogicalDisjunction
        tree.should.have.property 'left'
          .that.is.an.instanceof Node.BoolLiteral
        tree.should.have.property 'right'
          .that.is.an.instanceof Node.BoolLiteral

      it 'parses binary disjunction', ->
        checkDisjunction 'or'
        checkDisjunction 'OR'
        checkDisjunction 'oR'

      it 'handles precedence of binary logic', ->
        one   = number 1
        two   = number 2
        three = number 3
        four  = number 4
        five  = number 5
        six   = number 6

        both    = operator 'and'
        either  = operator 'or'
        less    = operator '<'
        equal   = operator '='
        greater = operator '>'

        left = parse [
          one, less, two, both, three, equal, four, either, five, greater, six
        ]
        right = parse [
          one, less, two, either, three, equal, four, both, five, greater, six
        ]

        leftTree = left.parse()
        rightTree = right.parse()

        leftTree.should.be.an.instanceof Node.LogicalDisjunction
        rightTree.should.be.an.instanceof Node.LogicalDisjunction

        leftTree.should.have.property 'left'
          .that.is.an.instanceof Node.LogicalConjunction
        rightTree.should.have.property 'right'
          .that.is.an.instanceof Node.LogicalConjunction

      it 'parses function calls', ->
        me = parse [
          reference ['foobar']
          openParen
          reference ['baz']
          comma
          reference ['qux']
          closeParen
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.FunctionCall
        tree.should.have.property 'function'
          .that.is.an.instanceof Node.Reference
        tree.should.have.deep.property 'parameters[0]'
          .that.is.an.instanceof Node.Reference
          .and.has.deep.property 'segments[0]', 'baz'
        tree.should.have.deep.property 'parameters[1]'
          .that.is.an.instanceof Node.Reference
          .and.has.deep.property 'segments[0]', 'qux'

      it 'parses parenthesized expressions', ->
        me = parse [
          number 1
          operator '*'
          openParen
          number 1
          operator '='
          number 2
          closeParen
        ]

        tree = me.parse()

        tree.should.be.an.instanceof Node.BinaryOperation
        tree.should.have.property 'operator', '*'

        tree.should.have.property 'right'
          .that.is.an.instanceof Node.BinaryOperation
          .and.has.property 'operator', '='
