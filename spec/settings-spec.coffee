{$} = require 'atom-space-pen-views'
SettingsView = require '../lib/settings-view'
fs = require 'fs'
Projects = require '../lib/projects'
path = require 'path'

describe 'Settings page', ->
  [cmd, dep, projects, project, view, fixturesPath] = []

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
    projects = new Projects('')
    view = new SettingsView({uri: 'atom://build-tools-settings', projects})
    expect(view.find('.list-group').children().length).toBe 1
    expect(view.find('.list-group').children()[0].children[0].innerHTML).toBe fixturesPath
    project = projects.getProject(fixturesPath)
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When a command is added', ->
    it 'adds the command to the command menu', ->
      project.addCommand cmd
      expect(view.find('.command #name').html()).toBe 'Test command'

  describe 'When a dependency is added', ->
    it 'adds the dependency to the dependency menu', ->
      cmd.name = 'Test command'
      project.addCommand cmd
      cmd.name = 'Test command 2'
      project.addCommand cmd
      project.addDependency dep
      expect(view.find('.dependency .text-success').html()).toBe 'Test command'

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
      project.addCommand cmd
      icon = view.find('.command .icon-edit')
      expect(icon.length).toBe 1
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
      cmd.name = 'Test command'
      project.addCommand cmd
      cmd.name = 'Test command 2'
      project.addCommand cmd
      project.addDependency dep
      icon = view.find('.dependency .icon-edit')
      expect(icon.length).toBe 1
      icon.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
