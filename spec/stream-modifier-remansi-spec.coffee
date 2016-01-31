Modifier = require '../lib/stream-modifiers/remansi'

fdescribe 'Stream Modifier - Remove ANSI', ->
  mod = null
  temp = null
  ret = null

  beforeEach ->
    mod = new Modifier.modifier

  describe 'On single line with escape code at the beginning and end', ->

    beforeEach ->
      temp = input: '\x1b[32mHello \x1b[35;41mbeautiful\x1b[33m world!\x1b[0m'
      ret = mod.modify temp: temp

    it 'removes the ANSI codes', ->
      expect(temp.input).toBe 'Hello beautiful world!'

    it 'returns null', ->
      expect(ret).toBe null

  describe 'On multi line', ->

    beforeEach ->
      temp = input: '\x1b[32mHello\x1b[41m'
      ret = mod.modify temp: temp

    it 'removes the ANSI codes', ->
      expect(temp.input).toBe 'Hello'

    it 'returns null', ->
      expect(ret).toBe null

    describe 'On second line', ->

      beforeEach ->
        temp = input: 'World\x1b['
        ret = mod.modify temp: temp

      it 'removes the ANSI codes', ->
        expect(temp.input).toBe 'World'

      it 'returns null', ->
        expect(ret).toBe null

      describe 'On third line', ->

        beforeEach ->
          temp = input: '01;33m!\x1b[0m'
          ret = mod.modify temp: temp

        it 'removes the ANSI codes', ->
          expect(temp.input).toBe '!'

        it 'returns null', ->
          expect(ret).toBe null

  describe 'On multi line with unsupported code', ->

    beforeEach ->
      temp = input: '\x1b[32mHello\x1b[24m\x1b[0K'
      ret = mod.modify temp: temp

    it 'removes the ANSI codes', ->
      expect(temp.input).toBe 'Hello'

    describe 'On second line', ->

      beforeEach ->
        temp = input: 'World\x1b['
        ret = mod.modify temp: temp

      it 'removes the ANSI codes', ->
        expect(temp.input).toBe 'World'
