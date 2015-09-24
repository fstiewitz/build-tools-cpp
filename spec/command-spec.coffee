Command = require '../lib/provider/command'

describe 'Command', ->
  _command = null
  command = null

  beforeEach ->
    _command = {
      project: '/home/fabian/.atom/packages/build-tools/spec/fixtures'
      name: 'Test'
      command: 'echo "Hello " World'
      wd: '.'
      modifier:
        queue:
          save_all: {}
        command:
          shell: {}
          wildcards: {}
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'nh'
      output:
        console:
          close_success: false
      version: 1
    }
    command = new Command(_command)

  it 'has all objects', ->
    expect(command.env).toBeDefined()

  describe 'on ::getSpawnInfo', ->
    it 'correctly splits the command', ->
      command.getSpawnInfo()
      expect(command.command).toBe 'echo'
      expect(command.args).toEqual ['Hello ', 'World']
