ProjectCache = require '../lib/provider/project-cache'
Providers = require '../lib/provider/provider'

path = require 'path'

describe 'Project Cache', ->
  module = null
  cache = null
  disp = null

  beforeEach ->
    module =
      availableSync: (p) ->
        path.join(p, '.build-tools.cson')

      model:
        class TestModel

          constructor: ->

          getCommands: ->
            [1, 2, 3]

          getCommandByName: (name) ->
            name

    disp = Providers.addModule 'test', module
    cache = new ProjectCache(atom.project.getPaths()[0])

  afterEach ->
    cache = null
    disp.dispose()

  describe 'On setDefault with all modules', ->
    def = null

    beforeEach ->
      def =
        whitelist: undefined
        blacklist: undefined
        keybindings: [
          ['test', 'test1']
          ['test', 'test2']
          ['test', 'test3']
        ]
      cache.setDefault 'test-folder', def

    it 'sets @default', ->
      expect(cache.default).toEqual def

    it 'sets the folder\'s config', ->
      expect(cache.folderConfigs['test-folder']).toEqual def

    describe 'On @getKeys', ->
      it 'returns the correct module keys', ->
        expect(ProjectCache.getKeys(def)).toEqual ['bt', 'test']

  describe 'On setDefault with a whitelist', ->
    def = null

    beforeEach ->
      def =
        whitelist: ['test']
        blacklist: undefined
        keybindings: [
          ['test', 'test1']
          ['test', 'test2']
          ['test', 'test3']
        ]
      cache.setDefault 'test-folder', def

    it 'sets @default', ->
      expect(cache.default).toEqual def

    it 'sets the folder\'s config', ->
      expect(cache.folderConfigs['test-folder']).toEqual def

    describe 'On @getKeys', ->
      it 'returns the correct module keys', ->
        expect(ProjectCache.getKeys(def)).toEqual ['test']

  describe 'On setDefault with a blacklist', ->
    def = null

    beforeEach ->
      def =
        whitelist: undefined
        blacklist: ['bt']
        keybindings: [
          ['test', 'test1']
          ['test', 'test2']
          ['test', 'test3']
        ]
      cache.setDefault 'test-folder', def

    it 'sets @default', ->
      expect(cache.default).toEqual def

    it 'sets the folder\'s config', ->
      expect(cache.folderConfigs['test-folder']).toEqual def

    describe 'On @getKeys', ->
      it 'returns the correct module keys', ->
        expect(ProjectCache.getKeys(def)).toEqual ['test']
