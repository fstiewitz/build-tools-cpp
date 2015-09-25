CommandModifier = require '../lib/pipeline/command-modifier'
Modifiers = require '../lib/modifier/modifier'
Command = require '../lib/provider/command'

describe 'Command Modifier', ->
  command = null
  module = null
  modifier = null

  beforeEach ->
    command = new Command({
      project: '/home/fabian/.atom/packages/build-tools/spec/fixtures'
      name: 'Test'
      command: 'echo Hello World'
      wd: '.'
      env: {}
      modifier:
        queue:
          test: {
            t: 1
          }
        command:
          shell:
            command: 'bash -c'
          test: {}
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'nh'
      output:
        console:
          close_success: false
      version: 1
      })
    out = {
      preSplit: (command) ->
        command.command += '!'
        return
    }
    module = Modifiers.addModule 'test', out
    modifier = new CommandModifier(command)

  afterEach ->
    module.dispose()

  it 'has the correct keys', ->
    expect(modifier.keys).toEqual ['shell', 'test']
    expect(modifier.preSplitKeys).toEqual ['test']
    expect(modifier.postSplitKeys).toEqual ['shell']

  describe 'On ::run', ->

    beforeEach ->
      waitsForPromise -> modifier.run()

    it 'returns the new command with splitted args', ->
      expect(command.command).toBe 'bash'
      expect(command.args).toEqual ['-c', 'echo Hello World!']
