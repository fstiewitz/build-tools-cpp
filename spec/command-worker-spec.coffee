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
      stdout:
        in: jasmine.createSpy('in')
        setType: jasmine.createSpy('setType')
      stderr:
        in: jasmine.createSpy('in')
        setType: jasmine.createSpy('setType')
        print: jasmine.createSpy('setType')
        linter: jasmine.createSpy('linter')
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
      expect(output.stdout.in).toHaveBeenCalledWith input: 'Hello World', files: []

  describe 'on error', ->

    beforeEach ->
      worker.process.error 'Test Error'

    it 'calls error of all outputs', ->
      promise.catch (error) ->
        expect(output.error).toHaveBeenCalledWith 'Test Error'

    it 'calls the error callback', ->
      promise.catch (error) ->
        expect(error).toBe 'Test Error'

  describe 'on finish', ->

    beforeEach ->
      worker.process.exit 0

    it 'calls exitCommand of all outputs', ->
      promise.then ->
        expect(output.exitCommand).toHaveBeenCalledWith 0

    it 'calls the finish callback', ->
      promise.then (finish) ->
        expect(finish).toBe 0
