OutputManager = require '../lib/pipeline/output-manager'

path = require 'path'

command =
    name: ''
    command: ''
    wd: '.' #Working directory. Default: .
    shell: false #Execute in shell
    wildcards: false #Replace wildcards
    save_all: false #Save all
    close_success: false #Close console on success
    stdout:
      #nh: No highlighting
      #ha: Highlight all
      #ht: Highlight tags
      #hc: Highlighting profile (requires 'profile')
      highlighting: 'ha'
      #gcc_clang: GCC/Clang
      #apm_test: apm test (Jasmine specs)
      #java: Java
      #python: Python
      #'profile': 'gcc_clang' #Uncomment if 'highlighting' is 'hc'
    stderr:
      highlighting: 'hc'
      profile: 'modelsim'
    #Backwards compatibility with older command versions (don't change it)
    version: 3

fdescribe 'Output Manager', ->
  manager = null
  output = null

  beforeEach ->
    output =
      newCommand: jasmine.createSpy('newCommand')
      exitCommand: jasmine.createSpy('exitCommand')
      stdout:
        in: jasmine.createSpy('in')
        setType: jasmine.createSpy('setType')
      stderr:
        in: jasmine.createSpy('in')
        setType: jasmine.createSpy('setType')
        print: jasmine.createSpy('setType')
        linter: jasmine.createSpy('linter')

    command.project = atom.project.getPaths()[0]
    manager = new OutputManager(command, [output])

  afterEach ->
    manager.destroy()

  it 'initalizes the output module', ->
    expect(output.newCommand).toHaveBeenCalledWith command

  describe 'On stdout input', ->
    it 'calls the correct functions', ->
      manager.stdout.in 'Hello World\n'
      expect(output.stdout.in).toHaveBeenCalledWith('Hello World')
      expect(output.stdout.setType).toHaveBeenCalledWith('warning')

  describe 'On stderr input', ->
    it 'calls the correct functions', ->
      input = '** Error: test.vhd(278): VHDL Compiler exiting'
      manager.stderr.in "#{input}\n"
      expect(output.stderr.in).toHaveBeenCalledWith input
      match = {type: 'error', message: 'VHDL Compiler exiting', file: path.join(atom.project.getPaths()[0], 'test.vhd'), row: '278', input: input}
      test = output.stderr.print.mostRecentCall.args[0]
      expect(test.input).toBe match.input
      expect(test.type).toBe match.type
      test = output.stderr.linter.mostRecentCall.args[0]
      expect(test.text).toBe match.message
      expect(test.type).toBe match.type
      expect(test.filePath).toBe match.file
      expect(test.range).toEqual [[277, 0], [277, 9999]]

  describe 'When command has finished', ->
    beforeEach ->
      manager.finish 0

    it 'sends the exit code to the module', ->
      expect(output.exitCommand).toHaveBeenCalledWith 0
