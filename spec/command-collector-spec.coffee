CommandCollector = require '../lib/provider/command-collector'
Providers = require '../lib/provider/provider'

path = require 'path'

describe 'Command Collector', ->
  module = null
  collector = null
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

    disp = Providers.addModule 'test', module
    collector = new CommandCollector(module.availableSync(atom.project.getPaths()[0]), ['test'])

  afterEach ->
    collector = null
    disp.dispose()

  describe 'On getCommands', ->
    commands = null

    beforeEach ->
      commands = collector.getCommands()

    it 'returns all commands', ->
      expect(commands).toEqual [1, 2, 3]
