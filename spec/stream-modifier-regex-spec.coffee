Modifier = require '../lib/stream-modifiers/regex'

describe 'Stream Modifiers - Regular Expression', ->
  mod = null
  config = null
  output = null
  temp = null
  perm = null

  beforeEach ->
    config =
      regex: '(?<file> .+?\\.(?:txt|html)):(?<row> \\d+)\\s(?<message>.+)'
      defaults: 'type: \'warning\''
    output =
      absolutePath: jasmine.createSpy('absolutePath').andCallFake (r) -> r
    Modifier.activate()
    mod = new Modifier.modifier(config, null, output)
    temp = {}
    perm = {}

  afterEach ->
    Modifier.deactivate()

  it 'creates the regular expression', ->
    expect(mod.regex).toBeDefined()

  it 'parses the defaults', ->
    expect(mod.default.type).toBe 'warning'

  describe 'On matching line', ->

    beforeEach ->
      temp.input = 'test.txt:10 Hello'
      mod.modify {temp, perm}

    it 'fills temp and perm with correct values', ->
      expect(temp.file).toBe 'test.txt'
      expect(temp.row).toBe '10'
      expect(temp.message).toBe 'Hello'
      expect(perm.file).toBe 'test.txt'
      expect(perm.row).toBe '10'
      expect(perm.message).toBe 'Hello'

    describe '::getFiles', ->
      ret = null

      beforeEach ->
        ret = mod.getFiles temp: temp, perm: perm

      it 'returns the correct file array', ->
        expect(ret).toEqual [{file: 'test.txt', start: 0, end: 7, row: '10', col: undefined}]

  describe 'On other lines', ->

    beforeEach ->
      temp.input = 'Something else'
      mod.modify {temp, perm}

    it 'doesn\'t fill temp and perm with values', ->
      expect(temp).toEqual {input: 'Something else'}
      expect(perm).toEqual {}

    describe '::getFiles', ->
      ret = null

      beforeEach ->
        ret = mod.getFiles temp: temp, perm: perm

      it 'returns an empty array', ->
        expect(ret.length).toBe 0
