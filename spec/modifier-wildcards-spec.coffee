Wildcards = require '../lib/modifier/wildcards'
Command = require '../lib/provider/command'
path = require 'path'

describe 'Command Modifier - Wildcards', ->
  command = null

  beforeEach ->
    command = new Command({
      project: '/home/fabian/.atom/packages/build-tools/spec/fixtures'
      name: 'Test'
      command: 'echo %f'
      wd: '.'
      env: {}
      modifier:
        queue:
          test: {
            t: 1
          }
        command:
          wildcards: {}
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'nh'
      output:
        console:
          close_success: false
      version: 1
    })
    jasmine.attachToDOM(atom.views.getView(atom.workspace))
    waitsForPromise -> atom.workspace.open path.join(atom.project.getPaths()[0], 'test.vhd')
    Wildcards.activate()
    waitsForPromise -> Wildcards.preSplit command

  it 'returns valid data', ->
    expect(command.command).toBe 'echo test.vhd'
