AnsiParser = require '../lib/output/ansi-parser'

describe 'AnsiParser', ->
  elements = null

  beforeEach ->
    element = document.createElement 'div'
    element.innerHTML = '<div></div>'
    elements = [element]

  describe 'On single line with escape code at the beginning and end', ->
    ret = null

    beforeEach ->
      ret = AnsiParser.getDelim '\x1b[32mHello \x1b[35;41mbeautiful\x1b[33m world!\x1b[0m', elements, 0

    it 'has one empty style', ->
      expect(ret[0]).toEqual [[0, 0, 0], 0, 0]

    it 'has the correct styling for "Hello"', ->
      expect(ret[1]).toEqual [[32, 0, 0], 0, 5]

    it 'has the correct styling for "beautiful"', ->
      expect(ret[2]).toEqual [[35, 41, 0], 11, 19]

    it 'has the correct styling for "world!"', ->
      expect(ret[3]).toEqual [[33, 41, 0], 28, 33]

    it 'has one empty style at the end', ->
      expect(ret[4]).toEqual [[0, 0, 0], 40, 44]

  describe 'On multi line', ->

    beforeEach ->
      AnsiParser.parseAnsi '\x1b[32mHello\x1b[41m', elements, 0

    it 'has the correct style', ->
      expect(elements[0].children.length).toBe 2
      expect(elements[0].children[1].innerText).toBe 'Hello'
      expect(elements[0].children[1].className).toBe 'a32 a0 a0'

    it 'has the correct attributes', ->
      expect(elements[0].children[1].getAttribute('nextStyle')).toBe 'a32 a41 a0'

    describe 'On second line', ->

      beforeEach ->
        elements.push document.createElement 'div'
        AnsiParser.parseAnsi 'World\x1b[', elements, 1

      it 'has the correct style', ->
        expect(elements[1].children.length).toBe 1
        expect(elements[1].children[0].innerText).toBe 'World'
        expect(elements[1].children[0].className).toBe 'a32 a41 a0'

      it 'has the correct attributes', ->
        expect(elements[1].children[0].getAttribute('endsWithAnsi')).toBe '\x1b['

      describe 'On third line', ->

        beforeEach ->
          elements.push document.createElement 'div'
          AnsiParser.parseAnsi '01;33m!\x1b[0m', elements, 2

        it 'has the correct style', ->
          expect(elements[2].children.length).toBe 1
          expect(elements[2].children[0].innerText).toBe '!'
          expect(elements[2].children[0].className).toBe 'a33 a41 a1'

        it 'has the correct attributes', ->
          expect(elements[2].children[0].getAttribute('nextStyle')).toBe 'a0 a0 a0'

  describe 'On multi line with unsupported code', ->

    beforeEach ->
      AnsiParser.parseAnsi '\x1b[32mHello\x1b[24m\x1b[0K', elements, 0

    it 'has the correct style', ->
      expect(elements[0].children.length).toBe 3
      expect(elements[0].children[1].innerText).toBe 'Hello'
      expect(elements[0].children[2].innerText).toBe '\x1b[0K'
      expect(elements[0].children[1].className).toBe 'a32 a0 a0'
      expect(elements[0].children[2].className).toBe 'a32 a0 a24'

    describe 'On second line', ->

      beforeEach ->
        elements.push document.createElement 'div'
        AnsiParser.parseAnsi 'World\x1b[', elements, 1

      it 'has the correct style', ->
        expect(elements[1].children.length).toBe 1
        expect(elements[1].children[0].innerText).toBe 'World'
        expect(elements[1].children[0].className).toBe 'a32 a0 a24'

      it 'has the correct attributes', ->
        expect(elements[1].children[0].getAttribute('endsWithAnsi')).toBe '\x1b['
