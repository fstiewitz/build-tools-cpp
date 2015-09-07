Projects = require '../lib/projects'
path = require 'path'

describe 'Local projects', ->
  fixturesPath = ''

  describe 'Test @hasLocal', ->
    it 'returns true', ->
      fixturesPath = atom.project.getPaths()[0]
      expect(Projects.hasLocal fixturesPath).toBe true

  describe 'Test @loadLocal', ->
    it 'returns a project instance', ->
      fixturesPath = atom.project.getPaths()[0]
      project = Projects.loadLocal fixturesPath
      expect(project).not.toBeNull()
      expect(project.save).toBeDefined()
      expect(project.commands.length).toBe 2
      expect(project.commands[0].project).toBe fixturesPath
      expect(project.commands[0].name).toBe 'Test'
      expect(project.commands[0].command).toBe 'echo Hello World'
      expect(project.commands[0].stderr.highlighting).toBe 'nh'
      expect(project.commands[0].version).toBe 3
