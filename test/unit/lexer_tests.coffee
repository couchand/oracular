# lexer tests

{should} = require '../helper'

{
  EOF
  Operator, Number, String, Reference
  OpenParen, CloseParen, Comma
} = require '../../src/spec/tokens'
StringLexer = require '../../src/spec/lexer'

describe 'StringLexer', ->
  describe '#', ->
    describe 'getToken', ->
      it 'is a function', ->
        me = new StringLexer()
        me.should.have.property 'getToken'
          .that.is.a 'function'

      it 'returns EOF', ->
        me = new StringLexer()

        tok = me.getToken()

        tok.should.have.property 'type', EOF

      it 'ignores comments', ->
        me = new StringLexer '# this is a comment'

        tok = me.getToken()

        tok.should.have.property 'type', EOF

      it 'ignores whitespace', ->
        me = new StringLexer '   \t   \r   \n'

        tok = me.getToken()

        tok.should.have.property 'type', EOF

      it 'lexes operators', ->
        me = new StringLexer '<=' + '>=' + '!=' + '<' + '>' + '+'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '<='

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '>='

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '!='

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '<'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '>'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', '+'

        me.getToken().should.have.property 'type', EOF

      it 'lexes and and or', ->
        me = new StringLexer 'and or AND OR'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', 'and'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', 'or'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', 'and'

        tok = me.getToken()
        tok.should.have.property 'type', Operator
        tok.should.have.property 'value', 'or'

      it 'lexes numbers', ->
        me = new StringLexer '42 4.2 -42 -4.2'

        tok = me.getToken()
        tok.should.have.property 'type', Number
        tok.should.have.property 'value', 42

        tok = me.getToken()
        tok.should.have.property 'type', Number
        tok.should.have.property 'value', 4.2

        tok = me.getToken()
        tok.should.have.property 'type', Number
        tok.should.have.property 'value', -42

        tok = me.getToken()
        tok.should.have.property 'type', Number
        tok.should.have.property 'value', -4.2

        me.getToken().should.have.property 'type', EOF

      it 'lexes single-quoted strings', ->
        me = new StringLexer "'foobar'"

        tok = me.getToken()
        tok.should.have.property 'type', String
        tok.should.have.property 'value', 'foobar'

        me.getToken().should.have.property 'type', EOF

      it 'lexes double-quoted strings', ->
        me = new StringLexer '"foobar"'

        tok = me.getToken()
        tok.should.have.property 'type', String
        tok.should.have.property 'value', 'foobar'

        me.getToken().should.have.property 'type', EOF

      it 'lexes single-quoted escaped single-quotes', ->
        me = new StringLexer "'\\'\\''"

        tok = me.getToken()
        tok.should.have.property 'type', String
        tok.should.have.property 'value', "''"

        me.getToken().should.have.property 'type', EOF

      it 'lexes double-quoted escaped double-quotes', ->
        me = new StringLexer '"\\"\\""'

        tok = me.getToken()
        tok.should.have.property 'type', String
        tok.should.have.property 'value', '""'

        me.getToken().should.have.property 'type', EOF

      it 'lexes references', ->
        me = new StringLexer 'foo foo.bar foo.bar.baz'

        tok = me.getToken()
        tok.should.have.property 'type', Reference
        tok.should.have.property 'value'
          .and.deep.equal ['foo']

        tok = me.getToken()
        tok.should.have.property 'type', Reference
        tok.should.have.property 'value'
          .and.deep.equal ['foo', 'bar']

        tok = me.getToken()
        tok.should.have.property 'type', Reference
        tok.should.have.property 'value'
          .and.deep.equal ['foo', 'bar', 'baz']

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

        me.getToken().should.have.property 'type', OpenParen
        me.getToken().should.have.property 'type', Comma
        me.getToken().should.have.property 'type', CloseParen
