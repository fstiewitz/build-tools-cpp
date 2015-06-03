{$} = require 'atom-space-pen-views'
SettingsView = require '../lib/settings-view'
fs = require 'fs'
Projects = require '../lib/projects'
path = require 'path'
temp = require('temp')

describe 'Settings page', ->
  [cmd, dep, projects, view, fixturesPath, filename] = []

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
      lint: false
    }
  }

  res = temp.openSync()
  filename = res.path
  fs.writeSync res.fd, '{}'
  fs.fsyncSync res.fd

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    dep = {
      from: fixturesPath,
      to: {
        project: 'Testproj',
        command: 'Testcmd'
      }
    }
    projects = new Projects(filename)
    view = new SettingsView({uri: 'atom://build-tools-settings', projects})
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When a project is added', ->
    it 'adds the project to the project menu', ->
      projects.addProject(fixturesPath)
      projects.getProject(fixturesPath).addCommand cmd
      projects.getProject(fixturesPath).addDependency dep
      expect(view.find('.list-group').children().length).toBe 1
      expect(view.find('.list-group').children()[0].children[0].innerHTML).toBe fixturesPath
      expect(view.find('.command #name').html()).toBe 'Test command'

  describe 'When multiple projects are open', ->
    it 'removes the shared path', ->
      expect(view.removeSharedPath ['abc/def','abc/ghj']).toEqual ['def','ghj']

  describe 'On edit/add command click', ->
    it 'opens command view', ->
      icon = view.find('.command .icon-edit')
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

  describe 'On edit/add dependency click', ->
    it 'opens the dependency view', ->
      projects.addProject('Testproj')
      icon = view.find('.dependency .icon-edit')
      expect(icon.length).toBe 1
      icon.click()
      dependencyview = atom.workspace.getModalPanels()[0].getItem()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      project_to = dependencyview.project_to[0]
      expect(project_to.children[project_to.selectedIndex].innerHTML).toBe 'Testproj'
      dependencyview.find('.buttons .icon-close').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      view.dependencyview.show(fixturesPath)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      project_from = dependencyview.project_from[0]
      expect(project_from.children[project_from.selectedIndex].innerHTML).toBe fixturesPath
      dependencyview.find('.buttons .icon-close').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      projects.removeProject('Testproj')


  describe 'When project file changes on disk', ->
    it 'reloads the view', ->
      CSON = require 'season'
      d = CSON.readFileSync projects.filename
      expect(d[fixturesPath]).toBeDefined()
      expect(d[fixturesPath].commands[0].name).toBe 'Test command'
      d[fixturesPath].commands[0].name = 'Test command 4'
      projects.getProject(fixturesPath).removeCommand 'Test command'
      waitsFor ->
        view.find('.command').length is 0
      runs ->
        CSON.writeFileSync projects.filename, d
        waitsFor ->
          view.find('.command').length is 1
        runs ->
          expect(view.find('.command #name').html()).toBe 'Test command 4'
          projects.watcher.close()

  temp.cleanupSync()
