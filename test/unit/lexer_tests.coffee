# lexer tests

{
  chai: {Assertion, util}
  should
} = require '../helper'

{
  EOF
  Operator, Number, String, Reference
  OpenParen, CloseParen, Comma
} = require '../../src/spec/token'
StringLexer = require '../../src/spec/lexer'

Assertion.addMethod 'token', (type, value) ->
  assertType = new Assertion @_obj, 'token assert type'

  util.transferFlags @, assertType, no

  assertType.property 'type', type

  if value?
    assertValue = new Assertion @_obj, 'token assert type'

    util.transferFlags @, assertValue, no

    if typeof value in ['string', 'number', 'boolean']
      assertValue.property 'value', value
    else
      assertValue.property 'value'
        .deep.equal value

describe 'StringLexer', ->
  describe '#', ->
    describe 'getToken', ->
      it 'is a function', ->
        me = new StringLexer()
        me.should.have.property 'getToken'
          .that.is.a 'function'

      it 'returns EOF', ->
        me = new StringLexer()
        me.getToken().should.be.a.token EOF

      it 'ignores comments', ->
        me = new StringLexer '# this is a comment'
        me.getToken().should.be.a.token EOF

      it 'ignores whitespace', ->
        me = new StringLexer '   \t   \r   \n'
        me.getToken().should.be.a.token EOF

      it 'lexes operators', ->
        me = new StringLexer '<=' + '>=' + '!=' + '<' + '>' + '+'

        me.getToken().should.be.a.token Operator, '<='
        me.getToken().should.be.a.token Operator, '>='
        me.getToken().should.be.a.token Operator, '!='
        me.getToken().should.be.a.token Operator, '<'
        me.getToken().should.be.a.token Operator, '>'
        me.getToken().should.be.a.token Operator, '+'
        me.getToken().should.be.a.token EOF

      it 'lexes and and or', ->
        me = new StringLexer 'and or AND OR'

        me.getToken().should.be.a.token Operator, 'and'
        me.getToken().should.be.a.token Operator, 'or'
        me.getToken().should.be.a.token Operator, 'and'
        me.getToken().should.be.a.token Operator, 'or'
        me.getToken().should.be.a.token EOF

      it 'lexes numbers', ->
        me = new StringLexer '42 4.2 -42 -4.2'

        me.getToken().should.be.a.token Number, 42
        me.getToken().should.be.a.token Number, 4.2
        me.getToken().should.be.a.token Number, -42
        me.getToken().should.be.a.token Number, -4.2
        me.getToken().should.be.a.token EOF

      it 'lexes single-quoted strings', ->
        me = new StringLexer "'foobar'"

        me.getToken().should.be.a.token String, 'foobar'
        me.getToken().should.be.a.token EOF

      it 'lexes double-quoted strings', ->
        me = new StringLexer '"foobar"'

        me.getToken().should.be.a.token String, 'foobar'
        me.getToken().should.be.a.token EOF

      it 'lexes single-quoted escaped single-quotes', ->
        me = new StringLexer "'\\'\\''"

        me.getToken().should.be.a.token String, "''"
        me.getToken().should.be.a.token EOF

      it 'lexes double-quoted escaped double-quotes', ->
        me = new StringLexer '"\\"\\""'

        me.getToken().should.be.a.token String, '""'
        me.getToken().should.be.a.token EOF

      it 'lexes references', ->
        me = new StringLexer 'foo foo.bar foo.bar.baz'

        me.getToken().should.be.a.token Reference, ['foo']
        me.getToken().should.be.a.token Reference, ['foo', 'bar']
        me.getToken().should.be.a.token Reference, ['foo', 'bar', 'baz']
        me.getToken().should.be.a.token EOF

      it 'errors on unfinished single-quotes', ->
        me = new StringLexer "'foobar"
        (-> me.getToken()).should.throw /not closed/i

      it 'errors on unfinished double-quotes', ->
        me = new StringLexer '"foobar'
        (-> me.getToken()).should.throw /not closed/i

      it 'errors on invalid input', ->
        me = new StringLexer '{foobar}'
        (-> me.getToken()).should.throw /invalid/i

      it 'lexes parentheses and commas', ->
        me = new StringLexer '(,)'

        me.getToken().should.be.a.token OpenParen
        me.getToken().should.be.a.token Comma
        me.getToken().should.be.a.token CloseParen
        me.getToken().should.be.a.token EOF
