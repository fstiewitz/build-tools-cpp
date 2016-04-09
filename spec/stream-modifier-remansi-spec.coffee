Modifier = require '../lib/stream-modifiers/remansi'

describe 'Stream Modifier - Remove ANSI', ->
  mod = null
  ret = null

  beforeEach ->
    mod = new Modifier.modifier

  describe 'On single line with escape code at the beginning and end', ->

    beforeEach ->
      ret = mod.modify_raw '\x1b[32mHello \x1b[35;41mbeautiful\x1b[33m world!\x1b[0m'

    it 'returns the new line', ->
      expect(ret).toBe 'Hello beautiful world!'

  describe 'On multi line', ->

    beforeEach ->
      ret = mod.modify_raw '\x1b[32mHello\x1b[41m'

    it 'returns the new line', ->
      expect(ret).toBe 'Hello'

    describe 'On second line', ->

      beforeEach ->
        ret = mod.modify_raw 'World\x1b['

      it 'returns the new line', ->
        expect(ret).toBe 'World'

      describe 'On third line', ->

        beforeEach ->
          ret = mod.modify_raw '01;33m!\x1b[0m'

        it 'returns the new line', ->
          expect(ret).toBe '!'

  describe 'On multi line with unsupported code', ->

    beforeEach ->
      ret = mod.modify_raw '\x1b[32mHello\x1b[24m\x1b[0K'

    it 'returns the new line', ->
      expect(ret).toBe 'Hello'

    describe 'On second line', ->

      beforeEach ->
        ret = mod.modify_raw 'World\x1b['

      it 'returns the new line', ->
        expect(ret).toBe 'World'
