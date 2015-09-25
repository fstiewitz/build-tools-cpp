Shell = require '../lib/modifier/shell'
Command = require '../lib/provider/command'

describe 'Command Modifier - Shell', ->
  command = null

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
    command.getSpawnInfo()
    Shell.postSplit command

  it 'returns valid data', ->
    expect(command.command).toBe 'bash'
    expect(command.args).toEqual ['-c', 'echo Hello World']
