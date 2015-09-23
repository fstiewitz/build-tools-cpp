Project = require '../lib/provider/project'
path = require 'path'

describe 'Project Configuration', ->
  instance = null
  folder = null
  file = null

  beforeEach ->
    folder = atom.project.getPaths()[0]
    file = path.join(folder, '.build-tools.cson')
    instance = new Project(folder, file)

  describe 'on ::getCommandByIndex with a valid id', ->
    command = null

    beforeEach ->
      command = instance.getCommandByIndex 0

    it 'returns the correct command', ->
      expect(command.name).toBe 'Test'

  describe 'on ::getCommandByIndex with an invalid id', ->
    command = null

    beforeEach ->
      command = instance.getCommandByIndex 2

    it 'returns the correct command', ->
      expect(command).toBeUndefined()
