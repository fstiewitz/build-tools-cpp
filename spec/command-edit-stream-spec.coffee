Pane = require '../lib/view/command-edit-stream-pipe'
Command = require '../lib/provider/command'

describe 'Stream Pipe Pane', ->
  view = null

  beforeEach ->
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
          {label: 'Highlight All', command: 'build-tools:add-stdout-all'}
          {label: 'Highlighting Profile', command: 'build-tools:add-stdout-profile'}
          {label: 'Regular Expression', command: 'build-tools:add-stdout-regex'}
          {label: 'Remove ANSI Codes', command: 'build-tools:add-stdout-remansi'}
        ]

    it 'loads no views', ->
      expect(view.panes).toEqual []
