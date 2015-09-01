{$} = require 'atom-space-pen-views'
SettingsView = require '../lib/settings-view'
Projects = require '../lib/projects'

describe 'Settings Page', ->
  [projects, view, fixturesPath] = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects('')
    projects.addProject fixturesPath
    projects.addProject 'fixtures2'
    projects.addProject 'fixtures3'
    view = new SettingsView({uri: '', projects})
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When page is shown', ->
    it 'shows all opened projects', ->
      expect(view.find('.project-item').length).toBe 1

    it 'shows the currently active project', ->
      expect(view.projectpane).toBeDefined()
      expect(view.activepane).toEqual view.projectpane

  describe 'When no active projects', ->

    beforeEach ->
      atom.project.removePath(fixturesPath)
      view.reload()

    it 'shows an error message', ->
      expect(view.pane.children().html()).toEqual view.errorpane.html()

  describe 'On "Show All"', ->

    beforeEach ->
      view.find('#show-all').click()

    it 'shows all available projects', ->
      expect(view.find('.project-item').length).toBe 3

    describe 'When clicking on project', ->
      it 'switches to that project', ->
        $(view.find('.project-item')[1]).click()
        expect(view.find('.active .icon').text()).toContain 'fixtures2'

  describe 'On ::showCommandPane', ->
    it 'shows the command pane', ->
      view.showCommandPane()
      expect(view.commandpane).toBeDefined()
      expect(view.activepane).toBe view.commandpane

  describe 'When multiple projects are open', ->
    it 'removes the shared path', ->
      expect(view.removeSharedPath ['/abc/def/ghi', '/abc/def/ghj', '/abc/klm/abc']).toEqual ['def/ghi', 'def/ghj', 'klm/abc']
