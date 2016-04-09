Modifier = new (require '../lib/stream-modifiers/all').modifier

describe 'Stream Modifier - All', ->
  describe 'on modify', ->
    t = null
    r = undefined

    beforeEach ->
      t = type: ''
      r = Modifier.modify temp: t

    it 'highlights the entire line', ->
      expect(t.type).toBe 'warning'

    it 'returns null', ->
      expect(r).toBe null
