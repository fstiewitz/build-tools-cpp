Pipeline = require '../lib/pipeline/output-pipeline'
Modifiers = require '../lib/stream-modifiers/modifiers'

path = require 'path'

describe 'Output Pipeline', ->
  pipe = null
  mod = null
  disp = null
  dest = null
  command = null
  inst = null
  callbacks = null

  beforeEach ->
    dest = jasmine.createSpy('destroy')
    command =
      project: atom.project.getPaths()[0]
      wd: '.'
      stdout:
        pipeline: [
          {
            name: 'test'
            config:
              a: 1
          }
        ]
    mod =
      modifier:
        class TestModifier

          constructor: (@config, @settings, @pipe) ->
            @modify = jasmine.createSpy('modify').andCallFake ({temp, perm}) ->
              temp.foo = 123
              perm.bar = 231
              temp.type = 'error'
              @pipe.setType temp
              1

            @destroy = dest

            @getFiles = jasmine.createSpy('getFiles').andCallFake ({temp, perm}) ->
              return [] unless temp.input isnt 'hello'
              [
                start: 0
                end: 10
                file: 'test.vhd'
              ]

          modify: ->

    callbacks =
      setType: jasmine.createSpy('setType')
      replacePrevious: jasmine.createSpy('replacePrevious')
      print: jasmine.createSpy('print')
      linter: jasmine.createSpy('linter')

    disp = Modifiers.addModule 'test', mod
    pipe = new Pipeline(command, command.stdout)
    pipe.subscribeToCommands callbacks, k, k for k in Object.keys(callbacks)
    inst = pipe.pipeline[0]
    spyOn(pipe, 'absolutePath').andCallThrough()
    spyOn(pipe, 'finishLine').andCallThrough()

  afterEach ->
    pipe.destroy()
    expect(dest).toHaveBeenCalled()
    disp.dispose()

  it 'initializes the modifier', ->
    expect(inst.config).toBe command.stdout.pipeline[0].config
    expect(inst.settings).toBe command
    expect(inst.pipe).toBe pipe

  describe 'on ::getFiles', ->
    ret = null

    beforeEach ->
      ret = pipe.getFiles(input: 'foo')

    it 'calls ::getFiles of all pipeline objects', ->
      expect(inst.getFiles).toHaveBeenCalled()
      expect(inst.getFiles.mostRecentCall.args).toEqual [{temp: {input: 'foo'}, perm: cwd: '.'}]

    it 'returns the correct array', ->
      expect(ret).toEqual [
        {
          start: 0
          end: 10
          file: path.join(atom.project.getPaths()[0], 'test.vhd')
        }
      ]

  describe 'on ::finishLine', ->

    describe 'without highlighting', ->

      beforeEach ->
        pipe.finishLine {input: 'hello'}, 'hello'

      it 'does not update anything', ->
        expect(callbacks.print).not.toHaveBeenCalled()
        expect(callbacks.linter).not.toHaveBeenCalled()
        expect(callbacks.setType).not.toHaveBeenCalled()

    describe 'with highlighting', ->

      beforeEach ->
        pipe.finishLine {input: 'hello', type: 'warning'}, 'hello'

      it 'calls only setType', ->
        expect(callbacks.print).not.toHaveBeenCalled()
        expect(callbacks.linter).not.toHaveBeenCalled()
        expect(callbacks.setType).toHaveBeenCalledWith 'warning'

    describe 'with highlighting and file matches', ->
      td = null

      beforeEach ->
        td = {input: 'foo', file: 'test.vhd', row: 10, type: 'warning', message: 'hello'}
        pipe.finishLine td, 'foo'

      it 'calls print and linter', ->
        expect(callbacks.print).toHaveBeenCalledWith input: td, files: [
          {
            start: 0
            end: 10
            file: path.join(atom.project.getPaths()[0], 'test.vhd')
          }
        ]
        expect(callbacks.linter.mostRecentCall.args[0]).toEqual
          type: 'warning'
          text: 'hello'
          filePath: path.join(atom.project.getPaths()[0], 'test.vhd')
          range: [[9, 0], [9, 9999]]
          trace: undefined
        expect(callbacks.setType).not.toHaveBeenCalled()

  describe 'on ::in', ->

    beforeEach ->
      pipe.in 'hello'

    it 'calls modify', ->
      expect(inst.modify).toHaveBeenCalled()

    it 'did not call finishLine', ->
      expect(pipe.finishLine).not.toHaveBeenCalled()

    it 'calls setType', ->
      expect(callbacks.setType).toHaveBeenCalledWith 'error'
