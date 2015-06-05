{$} = require 'atom-space-pen-views'
SettingsView = require '../lib/settings-view'
fs = require 'fs'
Projects = require '../lib/projects'
path = require 'path'
temp = require('temp')

describe 'Settings page', ->
  [cmd, dep, projects, view, fixturesPath, filename, fd] = []

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
  fd = res.fd
  fs.writeSync fd, '{}'
  fs.fsyncSync fd

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    dep = {
      from:
        project: fixturesPath
        command: 'Test command'
      to: {
        project: fixturesPath,
        command: 'Test command 2'
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
      cmd.name = 'Test command 2'
      projects.getProject(fixturesPath).addCommand cmd
      projects.getProject(fixturesPath).addDependency dep
      expect(view.find('.list-group').children().length).toBe 1
      expect(view.find('.list-group').children()[0].children[0].innerHTML).toBe fixturesPath
      expect(view.find('.command #name').html()).toBe 'Test command'

  describe 'When multiple projects are open', ->
    it 'removes the shared path', ->
      expect(view.removeSharedPath ['abc/def','abc/ghj']).toEqual ['def','ghj']

  describe 'On add command click', ->
    it 'opens the command view', ->
      button = view.find('#add-command-button')
      expect(button.length).toBe 1
      button.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy

  describe 'On edit command click', ->
    it 'opens command view', ->
      icon = view.find('.command .icon-edit')
      expect(icon.length).toBe 2
      icon.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()

  describe 'On add dependency click', ->
    it 'opens the dependency view', ->
      button = view.find('#add-dependency-button')
      expect(button.length).toBe 1
      button.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy

  describe 'On edit dependency click', ->
    it 'opens the dependency view', ->
      icon = view.find('.dependency .icon-edit')
      expect(icon.length).toBe 1
      icon.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()


  describe 'When project file changes on disk', ->
    it 'reloads the view', ->
      CSON = require 'season'
      d = CSON.readFileSync projects.filename
      expect(d[fixturesPath]).toBeDefined()
      expect(d[fixturesPath].commands[0].name).toBe 'Test command'
      d[fixturesPath].commands[0].name = 'Test command 4'
      CSON.writeFileSync projects.filename, d
      projects.reload()
      expect(projects.getProject(fixturesPath).commands[0].name).toBe 'Test command 4'
      projects.watcher.close()
      fs.close fd, =>
        fs.unlink filename
