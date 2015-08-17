Projects = require '../lib/projects'
path = require 'path'

describe 'Local projects', ->
  [fixturesPath] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]

  describe 'Test @hasLocal', ->
    expect(Projects.hasLocal fixturesPath).toBe true

  describe 'Test @loadLocal', ->
    console.log fixturesPath
    project = Projects.loadLocal fixturesPath
    expect(project).not.toBeNull()
    expect(project.commands.length).toBe 2
    expect(project.commands[0]).toEqual
      name: 'Test'
      command: 'echo Hello World'
      wd: '.'
      shell: false
      wildcards: false
      save_all: false
      close_success: false
      stdout:
        file: false
        highlighting: 'nh'
        lint: false
      stderr:
        file: false
        highlighting: 'hc'
        lint: false
      version: 2
