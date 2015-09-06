CommandWorker = require '../lib/pipeline/command-worker'
Command = require '../lib/command'

_command =
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
    highlighting: 'nh'
    #gcc_clang: GCC/Clang
    #apm_test: apm test (Jasmine specs)
    #java: Java
    #python: Python
    #'profile': 'gcc_clang' #Uncomment if 'highlighting' is 'hc'
  stderr:
    highlighting: 'ha'
  #Backwards compatibility with older command versions (don't change it)
  version: 3

describe 'Command Worker', ->
  worker = null
  output = null
  finish = null
  error = null
  command = null

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
    finish = jasmine.createSpy('finish')
    error = jasmine.createSpy('error')
    worker = new CommandWorker(command, [output], finish, error)

  afterEach ->
    worker.destroy()

  it 'calls newCommand of all outputs', ->
    expect(output.newCommand).toHaveBeenCalledWith command

  describe 'on input', ->

    beforeEach ->
      worker.manager.stdout.in 'Hello World\n'

    it 'calls stdout.in of all outputs', ->
      expect(output.stdout.in).toHaveBeenCalledWith 'Hello World'

  describe 'on error', ->

    beforeEach ->
      worker.process.error 'Test Error'

    it 'calls error of all outputs', ->
      expect(output.error).toHaveBeenCalledWith 'Test Error'

    it 'calls the error callback', ->
      expect(error).toHaveBeenCalledWith 'Test Error'

  describe 'on finish', ->

    beforeEach ->
      worker.process.exit 0

    it 'calls exitCommand of all outputs', ->
      expect(output.exitCommand).toHaveBeenCalledWith 0

    it 'calls the finish callback', ->
      expect(finish).toHaveBeenCalledWith 0
