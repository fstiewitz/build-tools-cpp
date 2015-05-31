{$} = require 'atom-space-pen-views'
SettingsView = require '../lib/settings-view'
fs = require 'fs'
Projects = require '../lib/projects'

describe 'Settings page', ->
  [data, projects, view, fixturesPath] = []

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

  beforeEach ->
    projects = new Projects('spec/build-tools-cpp.projects')
    projects.addProject fixturesPath
    view = new SettingsView({uri: 'atom://build-tools-settings', projects})
    projects.getProject(fixturesPath).addCommand data
    jasmine.attachToDOM(view.element)
    fixturesPath = atom.project.getPaths()[0]

  afterEach ->
    projects.destroy()
    fs.unlinkSync 'spec/build-tools-cpp.projects'
    view.destroy()

  describe 'When a project is added', ->
    it 'adds the project to the project menu', ->
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
