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
    spyOn(instance, 'save')

  afterEach ->
    instance.destroy()

  describe 'on ::getCommandByIndex with a valid id', ->
    command = null

    beforeEach ->
      p = instance.getCommandByIndex 0
      p.then (c) -> command = c
      waitsForPromise -> p

    it 'returns the correct command', ->
      expect(command.name).toBe 'Test'

  describe 'on ::getCommandById on the second provider', ->
    command = null

    beforeEach ->
      p = instance.getCommandById 1, 1
      p.then (c) -> command = c
      waitsForPromise -> p

    it 'returns the correct command', ->
      expect(command.name).toBe 'Bar 2'

  describe 'on ::getCommandNameObjects', ->
    commands = null

    beforeEach ->
      p = instance.getCommandNameObjects()
      p.then (cs) -> commands = cs
      waitsForPromise -> p

    it 'returns the correct commands', ->
      expect((c.name for c in commands)).toEqual ['Test', 'Bar', 'Bar 2', 'Bar', 'Bar 2']

  describe 'on ::addProvider', ->

    beforeEach ->
      instance.addProvider 'bt'

    it 'adds the provider', ->
      expect(instance.providers[3].key).toBe 'bt'

    it 'calls save', ->
      expect(instance.save).toHaveBeenCalled()

  describe 'on ::removeProvider', ->

    beforeEach ->
      instance.removeProvider 2

    it 'adds the provider', ->
      expect(instance.providers[2]).toBeUndefined()

    it 'calls save', ->
      expect(instance.save).toHaveBeenCalled()

  describe 'on ::moveProviderUp', ->

    beforeEach ->
      instance.moveProviderUp 1

    it 'moves the provider', ->
      expect(instance.providers[0].key).toBe 'bte'
      expect(instance.providers[1].key).toBe 'bt'

    it 'calls save', ->
      expect(instance.save).toHaveBeenCalled()

  describe 'on ::moveProviderDown', ->

    beforeEach ->
      instance.moveProviderDown 0

    it 'moves the provider', ->
      expect(instance.providers[0].key).toBe 'bte'
      expect(instance.providers[1].key).toBe 'bt'

    it 'calls save', ->
      expect(instance.save).toHaveBeenCalled()
