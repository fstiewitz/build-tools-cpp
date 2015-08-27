LocalSettingsView = require '../lib/local-settings-view'
Profiles = require '../lib/profiles/profiles'
Projects = require '../lib/projects'

describe 'Local settings page', ->
  {project, view, fixturesPath, projects} = []

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    project = Projects.loadLocal fixturesPath
    projects = new Projects('')
    expect(project).not.toBeNull()
    view = new LocalSettingsView({uri: '.build-tools.cson', projects, project, profiles: Profiles})
    jasmine.attachToDOM view.element

  afterEach ->
    view.destroy()
    project.destroy()
    projects.destroy()

  describe 'When opening the file', ->
    it 'opens the settings page', ->
      expect(view.projectpane).toBeDefined()
      expect(view.activepane).toEqual view.projectpane
      expect(view.projectpane.children()[1].children.length).toBe 1
      expect(view.filechange).toBeDefined()
