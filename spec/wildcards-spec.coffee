path = require 'path'
Command = require '../lib/command'

describe 'Console View', ->
  [workspaceElement, openPromise, command, fixturesPath, data] = []

  data = {}

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)
    fixturesPath = atom.project.getPaths()[0]
    openPromise = atom.workspace.open(path.join(fixturesPath,'src','test.c'))
    data = {
      project: fixturesPath
      name: 'Test command',
      command: '\\%f %f, \\%b %b, \\%d %d, \\%e %e',
      wd: 'build',
      shell: false,
      wildcards: false,
      stdout: {
        file: false,
        highlighting: 'ha',
        lint: false
      }
      stderr: {
        file: true,
        highlighting: 'hc',
        profile: 'gcc_clang',
        lint: false
      }
    }
    command = new Command(data)
    waitsForPromise -> openPromise
    runs ->

  describe 'When the package detects wildcards', ->
    it 'replaces them correctly', ->
      expect(command.replaceWildcards().command).toBe command.command
      command.wildcards = true
      file = path.join('..','src','test.c')
      base = 'test.c'
      folder = path.join('..','src')
      ext = 'test'
      expect(command.replaceWildcards().command).toBe "%f #{file}, %b #{base}, %d #{folder}, %e #{ext}"
