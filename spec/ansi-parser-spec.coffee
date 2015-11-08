AnsiParser = require '../lib/output/ansi-parser'

describe 'AnsiParser', ->
  element = null

  beforeEach ->
    element = document.createElement 'div'
    element.innerHTML = '<div></div>'

  describe 'On single line with escape code at the beginning and end', ->
    ret = null

    beforeEach ->
      ret = AnsiParser.getDelim '\x1b[32mHello \x1b[35;41mbeautiful\x1b[33m world!\x1b[0m', [element]

    it 'has one empty style', ->
      expect(ret[0]).toEqual [[0, 0], 0, 0]

    it 'has the correct styling for "Hello"', ->
      expect(ret[1]).toEqual [[32, 0], 0, 5]

    it 'has the correct styling for "beautiful"', ->
      expect(ret[2]).toEqual [[35, 41], 11, 19]

    it 'has the correct styling for "world!"', ->
      expect(ret[3]).toEqual [[33, 41], 28, 33]

    it 'has one empty style at the end', ->
      expect(ret[4]).toEqual [[0, 0], 40, 44]
