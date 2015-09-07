QueueWorker = require '../lib/pipeline/queue-worker'
Command = require '../lib/command'

_command = [
  {
    name: 'Test 1'
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
    output:
      test:
        close_success: true
    #Backwards compatibility with older command versions (don't change it)
    version: 3
  }
  {
    name: 'Test 2'
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
    output:
      test:
        close_success: true
    #Backwards compatibility with older command versions (don't change it)
    version: 3
  }
  {
    name: 'Test 3'
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
    output:
      test:
        close_success: true
    #Backwards compatibility with older command versions (don't change it)
    version: 3
  }
]

describe 'Queue Worker', ->
  worker = null
  output = null
  command = null

  beforeEach ->
    command = []
    for c in _command
      c.project = atom.project.getPaths()[0]
      comm = new Command(c)
      comm.output = test: {}
      command.push comm

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

    worker = new QueueWorker({queue: command}, {test: output})
    spyOn(worker, 'finishedCommand').andCallThrough()
    spyOn(worker, 'errorCommand').andCallThrough()

  afterEach ->
    worker.destroy()

  it 'calls newQueue of all outputs', ->
    expect(output.newQueue).toHaveBeenCalledWith queue: command

  describe 'on run', ->

    beforeEach ->
      worker.run()

    it 'calls newCommand of all outputs', ->
      expect(output.newCommand.mostRecentCall.args[0].name).toBe 'Test 1'

  describe 'on finish with a successful exit code', ->

    beforeEach ->
      worker.run().process.exit 0

    it 'calls finishedCommand', ->
      expect(worker.finishedCommand).toHaveBeenCalledWith 0

    it 'calls exitCommand of all outputs', ->
      expect(output.exitCommand).toHaveBeenCalledWith 0

    it 'executes the next command', ->
      expect(output.newCommand.mostRecentCall.args[0].name).toBe 'Test 2'

  describe 'on finish with a error code', ->

    beforeEach ->
      worker.run().process.exit 1

    it 'calls finishedCommand', ->
      expect(worker.finishedCommand).toHaveBeenCalledWith 1

    it 'calls exitCommand of all outputs', ->
      expect(output.exitCommand).toHaveBeenCalledWith 1

    it 'calls exitQueue of all outputs', ->
      expect(output.exitQueue).toHaveBeenCalledWith 1

    it 'does not execute the next command', ->
      expect(output.newCommand.mostRecentCall.args[0].name).not.toBe 'Test 2'

    it 'sets the finished flag', ->
      expect(worker.hasFinished()).toBe true

  describe 'on error', ->

    beforeEach ->
      worker.run().process.error 'Test Error'

    it 'calls errorCommand', ->
      expect(worker.errorCommand).toHaveBeenCalledWith 'Test Error'

    it 'calls error of all outputs', ->
      expect(output.error).toHaveBeenCalledWith 'Test Error'

    it 'calls exitQueue of all outputs', ->
      expect(output.exitQueue).toHaveBeenCalledWith -1

    it 'does not call exitCommand of all outputs', ->
      expect(output.exitCommand).not.toHaveBeenCalled()

    it 'does not execute the next command', ->
      expect(output.newCommand.mostRecentCall.args[0].name).not.toBe 'Test 2'

    it 'sets the finished flag', ->
      expect(worker.hasFinished()).toBe true

  describe 'on stop', ->

    beforeEach ->
      worker.run()
      worker.stop()

    it 'calls exitQueue of all outputs', ->
      expect(output.exitQueue).toHaveBeenCalledWith -2

    it 'does not execute the next command', ->
      expect(output.newCommand.mostRecentCall.args[0].name).not.toBe 'Test 2'

    it 'sets the finished flag', ->
      expect(worker.hasFinished()).toBe true
