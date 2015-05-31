{$} = require 'atom-space-pen-views'

describe 'Settings page', ->
  [workspaceElement, activationPromise, view, fixturesPath] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('build-tools-cpp')
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:settings')
    waitsForPromise -> activationPromise
    runs ->
      jasmine.attachToDOM(workspaceElement)
      fixturesPath = atom.project.getPaths()[0]
      view = atom.workspace.getActivePaneItem()

  describe 'On build-tools-cpp:settings', ->
    it 'shows the settings page', ->
      expect(view).toBeDefined()
      expect(view.getURI()).toBe 'atom://build-tools-settings'

    describe 'When a project is added', ->
      it 'adds the project to the project menu', ->
        expect(view).toBeDefined()
        expect(view.find('.list-group').children().length).toBe 1
        expect(view.find('.list-group').children()[0].children[0].innerHTML).toBe fixturesPath

    describe 'When multiple projects are open', ->
      it 'removes the shared path', ->
        expect(view.removeSharedPath ['abc/def','abc/ghj']).toEqual ['def','ghj']

  describe 'On edit command click', ->
    it 'opens command view', ->
      icon = view.find('.icon-edit')
      expect(icon.length).toBe 1
      icon.click()
      commandview = atom.workspace.getModalPanels()[0].getItem()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(commandview.nameEditor.getText()).toBe 'Test command'
      atom.commands.dispatch(commandview.element, 'core:cancel')
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      view.commandview.show()
      commandview = atom.workspace.getModalPanels()[0].getItem()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(commandview.nameEditor.getText()).toBe ''
      atom.commands.dispatch(commandview.element, 'core:cancel')
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
