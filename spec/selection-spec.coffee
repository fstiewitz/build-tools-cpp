SelectionView = require '../lib/selection-view'
Projects = require '../lib/projects'
{$} = require 'atom-space-pen-views'

describe 'Command Selection Panel', ->
  [spy, view, projects, project, fixturesPath] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects('')
    projects.addProject(fixturesPath) if not projects.getProject(fixturesPath)?
    project = projects.getProject fixturesPath
    spy = jasmine.createSpy('callback')
    view = new SelectionView

  afterEach ->
    projects.destroy()

  describe 'When project has commands', ->
    view = null

    cmd = {
      name: 'Test command',
      command: 'pwd "Hello World" test',
      wd: 'sub0',
      shell: false,
      wildcards: false,
      stdout: {
        file: false,
        highlighting: 'ha',
        lint: false
      }
      stderr: {
        file: true,
        highlighting: 'hc',
        profile: 'python',
        lint: false
      }
    }

    beforeEach ->
      cmd.name = 'Test command'
      project.addCommand cmd
      cmd.name = 'Test command 2'
      project.addCommand cmd
      view.show(project, spy)
      jasmine.attachToDOM(view.element)

    afterEach ->
      view.detach()

    describe 'On view creation', ->
      it 'opens the selection view with two elements', ->
        expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
        expect(view.find('.two-lines').length).toBe 2

    describe 'On element selection', ->
      it 'calls the callback function', ->
        $(view.find('.two-lines')[0]).mouseup()
        expect(spy).toHaveBeenCalledWith 'Test command'

    describe 'On cancel', ->
      it 'cancels', ->
        atom.commands.dispatch(view.element,'core:cancel')
        expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
        expect(spy).not.toHaveBeenCalled()

  describe 'When project has no commands', ->
    view = null

    beforeEach ->
      view.show(project, spy)
      jasmine.attachToDOM(view.element)

    afterEach ->
      view.detach()

    describe 'On view creation', ->
      it 'opens the selection view with two elements', ->
        expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
        expect(view.find('.two-lines').length).toBe 0

    describe 'On cancel', ->
      it 'cancels', ->
        atom.commands.dispatch(view.element,'core:cancel')
        expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
        expect(spy).not.toHaveBeenCalled()
