CommandWorker = require '../lib/pipeline/command-worker'
Command = require '../lib/provider/command'

_command =
  name: ''
  command: ''
  wd: '.'
  stdout:
    highlighting: 'nh'
  stderr:
    highlighting: 'ha'
  version: 1

describe 'Command Worker', ->
  worker = null
  output = null
  command = null
  promise = null

  beforeEach ->
    command = new Command(_command)
    output =
      newQueue: jasmine.createSpy('newQueue')
      newCommand: jasmine.createSpy('newCommand')
      exitCommand: jasmine.createSpy('exitCommand')
      exitQueue: jasmine.createSpy('exitQueue')
      stdout_in: jasmine.createSpy('stdout_in')
      stdout_setType: jasmine.createSpy('stdout_setType')
      stderr_in: jasmine.createSpy('stderr_in')
      stderr_setType: jasmine.createSpy('stderr_setType')
      stderr_print: jasmine.createSpy('stderr_setType')
      stderr_linter: jasmine.createSpy('stderr_linter')
      error: jasmine.createSpy('error')

    command.project = atom.project.getPaths()[0]
    worker = new CommandWorker(command, [output])
    promise = worker.run()

  afterEach ->
    worker.destroy()

  it 'calls newCommand of all outputs', ->
    expect(output.newCommand).toHaveBeenCalledWith command

  describe 'on input', ->

    beforeEach ->
      worker.manager.stdout.in 'Hello World\n'

    it 'calls stdout.in of all outputs', ->
      expect(output.stdout_in).toHaveBeenCalledWith input: 'Hello World', files: []

  describe 'on error', ->

    beforeEach ->
      worker.environment.process.error 'Test Error'

    it 'calls error of all outputs', ->
      expect(output.error).toHaveBeenCalledWith 'Test Error'

    it 'does not call exitCommand', ->
      expect(output.exitCommand).not.toHaveBeenCalled()

  describe 'on finish', ->

    beforeEach ->
      worker.environment.process.exit 0
      waitsForPromise -> promise

    it 'calls exitCommand of all outputs', ->
      promise.then ->
        expect(output.exitCommand).toHaveBeenCalledWith 0

    it 'calls the finish callback', ->
      promise.then (finish) ->
        expect(finish).toBe 0

  describe 'on stop', ->

    beforeEach ->
      worker.kill()
      waitsForPromise -> promise

    it 'does not call exitCommand', ->
      expect(output.exitCommand).toHaveBeenCalledWith null

    it 'calls the finish callback', ->
      promise.then (finish) ->
        expect(finish).toBe null
