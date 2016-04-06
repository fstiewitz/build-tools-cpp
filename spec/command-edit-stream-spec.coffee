Pane = require '../lib/view/command-edit-stream-pane'
Command = require '../lib/provider/command'
Modifiers = require '../lib/stream-modifiers/modifiers'

{$} = require 'atom-space-pen-views'

describe 'Stream Pipe Pane', ->
  view = null

  beforeEach ->
    Modifiers.reset()
    view = new Pane
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.remove()

  it 'initializes the view', ->
    expect(view.panes).toEqual []

  describe 'on ::set with empty command', ->
    command = null

    beforeEach ->
      spyOn(atom.contextMenu, 'add').andCallThrough()
      command = new Command
      view.set command, 'stdout'

    it 'sets up the context menu', ->
      expect(atom.contextMenu.add).toHaveBeenCalledWith
        '.stdout #add-modifier': [
          {label: 'Highlight All', command: 'build-tools:add-all'}
          {label: 'Highlighting Profile', command: 'build-tools:add-profile'}
          {label: 'Regular Expression', command: 'build-tools:add-regex'}
          {label: 'Remove ANSI Codes', command: 'build-tools:add-remansi'}
        ]

    it 'loads no views', ->
      expect(view.panes).toEqual []

    describe 'On add module', ->

      beforeEach ->
        spyOn(view, 'initializePane')
        view.addModifier('all')
        view.addModifier('remansi')

      it 'adds the module\'s pane', ->
        expect(view.panes[0].key).toBe 'all'
        expect(view.panes[0].view.get).toBeDefined()
        expect(view.panes[1].key).toBe 'remansi'
        expect(view.panes[1].view.get).toBeDefined()
        expect(view.panes_view[0].children.length).toBe 2

      it 'initializes the module', ->
        args = view.initializePane.calls[0].args
        expect(args[0]).toBe view.panes[0].view
        expect(args[1]).toBeUndefined()
        args = view.initializePane.calls[1].args
        expect(args[0]).toBe view.panes[1].view
        expect(args[1]).toBeUndefined()

    describe 'On remove module', ->

      beforeEach ->
        view.addModifier('all')
        view.addModifier('remansi')
        view.removeModifier 1

      it 'removes the module pane', ->
        expect(view.panes_view[0].children.length).toBe 1

      it 'removes the module data', ->
        expect(view.panes.length).toBe 1
        expect(view.panes[0].key).toBe 'all'

    describe 'On move', ->

      beforeEach ->
        view.addModifier('all')
        view.addModifier('remansi')

      it 'moves the modifier up', ->
        view.moveModifierUp 1
        expect(view.panes[0].key).toBe 'remansi'
        expect(view.panes[1].key).toBe 'all'
        expect(view.panes_view.children()[0]).toBe view.panes[0].pane[0]

      it 'moves the modifier down', ->
        view.moveModifierDown 0
        expect(view.panes[0].key).toBe 'remansi'
        expect(view.panes[1].key).toBe 'all'
        expect(view.panes_view.children()[1]).toBe view.panes[1].pane[0]

  describe 'on ::set with defined command', ->
    command = null
    module = null
    mod = null
    disp = null

    beforeEach ->
      module =
        name: 'Test Module'
        edit:
          class TestSaver
            constructor: ->
              @get = jasmine.createSpy('get').andCallFake (c) ->
                c.stdout.pipeline.push
                  name: 'testmodule'
                  config:
                    a: 2
                null
              @set = jasmine.createSpy('set')
              @destroy = jasmine.createSpy('destroy')
              mod = this
      disp = Modifiers.addModule 'testmodule', module
      command = new Command
      command.oldname = 'foo'
      command.stdout.pipeline.push
        name: 'testmodule'
        config:
          a: 1
      view.set command, 'stdout'

    afterEach ->
      disp.dispose()

    it 'adds one modifier', ->
      expect(mod.set).toHaveBeenCalledWith command, command.stdout.pipeline[0].config, 'stdout', undefined

    it 'adds the view', ->
      expect(view.panes[0].key).toBe 'testmodule'
      expect(view.panes_view.children()[0]).toBe view.panes[0].pane[0]

    describe 'on ::get', ->
      command2 = null
      ret = null

      beforeEach ->
        command2 = new Command
        ret = view.get command2, 'stdout'

      it 'calls ::get of modifier', ->
        expect(mod.get).toHaveBeenCalledWith command2, 'stdout'

      it 'sets the new command', ->
        expect(command2.stdout.pipeline[0]).toEqual
          name: 'testmodule'
          config:
            a: 2

      it 'returns nothing', ->
        expect(ret).toBeNull()

    describe 'on destroy', ->

      beforeEach ->
        view.remove()

      it 'removes all panes', ->
        expect(view.panes_view[0].children.length).toBe 0

      it 'calls ::destroy of all modifiers', ->
        expect(mod.destroy).toHaveBeenCalled()
