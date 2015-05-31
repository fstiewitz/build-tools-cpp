{$} = require 'atom-space-pen-views'
main = require '../lib/main'

describe 'Settings page', ->
  [workspaceElement, activationPromise, view, fixturesPath] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)
    activationPromise = atom.packages.activatePackage('build-tools-cpp')
    atom.commands.dispatch(workspaceElement, 'build-tools-cpp:settings')
    waitsForPromise -> activationPromise
    runs ->
      fixturesPath = atom.project.getPaths()[0]
      waitsFor ->
        atom.workspace.getActivePaneItem()?.getURI() is 'atom://build-tools-settings'
      runs ->
        view = atom.workspace.getActivePaneItem()
        expect(view).toBeDefined()
        if (project = main.projects.getProject fixturesPath) is undefined
          main.projects.addProject fixturesPath
          data = {
            name: 'Test command',
            command: 'pwd "Hello World" test',
            wd: 'sub0',
            shell: false,
            stdout: {
              file: false,
              highlighting: 'ha',
              lint: false
            }
            stderr: {
              file: true,
              highlighting: 'hc',
              lint: false
            }
          }
          main.projects.getProject(fixturesPath).addCommand data


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

      describe 'On edit/add command click', ->
        it 'opens command view', ->
          view.reload()
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
