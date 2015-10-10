Env = require '../lib/modifier/env'
Command = require '../lib/provider/command'

describe 'Command Modifier - Environment Variables', ->
  command = null

  beforeEach ->
    command = new Command({
      project: '/home/fabian/.atom/packages/build-tools/spec/fixtures'
      name: 'Test'
      command: 'echo Hello World'
      wd: '.'
      env: {}
      modifier:
        env:
          TEST1: 'Hello'
          PWD: '/'
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'nh'
      output:
        console:
          close_success: false
      version: 1
    })
    command.getSpawnInfo()
    Env.preSplit command

  it 'returns valid data', ->
    expect(command.env['TEST1']).toBe 'Hello'
    expect(command.env['PWD']).toBe '/'
