OutputManager = require '../lib/pipeline/output-manager'

path = require 'path'

command =
    name: ''
    command: ''
    wd: '.'
    stdout:
      highlighting: 'ha'
    stderr:
      highlighting: 'hc'
      profile: 'modelsim'
    version: 1

describe 'Output Manager', ->
  manager = null
  output = null

  beforeEach ->
    output =
      newCommand: jasmine.createSpy('newCommand')
      exitCommand: jasmine.createSpy('exitCommand')
      stdout_in: jasmine.createSpy('stdout_in')
      stdout_setType: jasmine.createSpy('stdout_setType')
      stderr_in: jasmine.createSpy('stderr_in')
      stderr_setType: jasmine.createSpy('stderr_setType')
      stderr_print: jasmine.createSpy('stderr_setType')
      stderr_linter: jasmine.createSpy('stderr_linter')

    command.project = atom.project.getPaths()[0]
    manager = new OutputManager(command, [output])

  afterEach ->
    manager.destroy()

  it 'initalizes the output module', ->
    expect(output.newCommand).toHaveBeenCalledWith command

  describe 'On stdout input', ->
    it 'calls the correct functions', ->
      manager.stdout.in 'Hello World\n'
      expect(output.stdout_in).toHaveBeenCalledWith input: 'Hello World', files: []
      expect(output.stdout_setType).toHaveBeenCalledWith('warning')

  describe 'On stderr input', ->
    it 'calls the correct functions', ->
      input = '** Error: test.vhd(278): VHDL Compiler exiting'
      manager.stderr.in "#{input}\n"
      expect(output.stderr_in.mostRecentCall.args[0].input).toBe input
      match = {type: 'error', message: 'VHDL Compiler exiting', file: path.join(atom.project.getPaths()[0], 'test.vhd'), row: '278', input: input}
      test = output.stderr_print.mostRecentCall.args[0].input
      expect(test.input).toBe match.input
      expect(test.type).toBe match.type
      test = output.stderr_linter.mostRecentCall.args[0]
      expect(test.text).toBe match.message
      expect(test.type).toBe match.type
      expect(test.filePath).toBe match.file
      expect(test.range).toEqual [[277, 0], [277, 9999]]

  describe 'When command has finished', ->
    beforeEach ->
      manager.finish 0

    it 'sends the exit code to the module', ->
      expect(output.exitCommand).toHaveBeenCalledWith 0
