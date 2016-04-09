Pipeline = require '../lib/pipeline/output-pipeline-raw'
Modifiers = require '../lib/stream-modifiers/modifiers'

describe 'Raw Output Pipeline', ->
  pipe = null
  mod = null
  disp = null
  dest = null

  beforeEach ->
    dest = jasmine.createSpy('destroy')
    mod =
      modifier:
        class TestModifier

          constructor: (@config, @settings) ->
            @modify_raw = jasmine.createSpy('modify_raw').andCallFake (i) -> "#{i} World!"
            @destroy = dest

          modify_raw: ->

    disp = Modifiers.addModule 'test', mod
    pipe = new Pipeline({b: 1}, pipeline: [{name: 'test', config: {a: 1}}])

  afterEach ->
    pipe.destroy()
    expect(dest).toHaveBeenCalled()
    disp.dispose()

  it 'creates the pipeline', ->
    expect(pipe.pipeline[0].config).toEqual a: 1

  describe 'on input', ->
    ret = null

    beforeEach ->
      ret = pipe.in 'Hello'

    it 'calls modify_raw of all modifiers', ->
      expect(pipe.pipeline[0].modify_raw).toHaveBeenCalledWith 'Hello'

    it 'returns the new value', ->
      expect(ret).toBe 'Hello World!'
