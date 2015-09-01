{$} = require 'atom-space-pen-views'
ProjectPane = require '../lib/project-pane'
Projects = require '../lib/projects'

describe 'Project Pane', ->
  [cmd, dep, projects, project, view, fixturesPath, spy] = []

  cmd = {
    name: 'Test command',
    command: 'pwd "Hello World" test',
    wd: 'sub0',
    shell: false,
    wildcards: false,
    save_all: false,
    close_success: false,
    stdout: {
      file: false,
      highlighting: 'ha',
      lint: false
    }
    stderr: {
      file: true,
      highlighting: 'hc',
      profile: 'apm_test',
      lint: false
    }
    version: 2
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
    projects.addProject fixturesPath
    spy = jasmine.createSpy('spy')
    view = new ProjectPane(projects, spy)
    project = projects.getProject(fixturesPath)
    view.setContent project, 'Test'
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When a command is added', ->
    it 'adds the command to the command menu', ->
      project.addCommand cmd
      view.setContent project, 'Test'
      expect(view.find('.command #name').html()).toBe 'Test command'

  describe 'When setting a custom key binding', ->
    it 'opens the import view', ->
      btn = view.find('#make').find('#custom')
      btn.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(btn.hasClass('selected')).toBeFalsy()

  describe 'When a dependency is added', ->
    it 'adds the dependency to the dependency menu', ->
      cmd.name = 'Test command'
      project.addCommand cmd
      cmd.name = 'Test command 2'
      project.addCommand cmd
      project.addDependency dep
      view.setContent project, 'Test'
      expect(view.find('.dependency .text-info').html()).toBe 'Test command'

  describe 'On add command click', ->
    it 'opens the command view', ->
      button = view.find('#add-command-button')
      expect(button.length).toBe 1
      button.click()
      expect(spy).toHaveBeenCalledWith null, null, project

  describe 'On import command click', ->
    it 'opens the import view', ->
      button = view.find('#import-command-button')
      expect(button.length).toBe 1
      button.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy

  describe 'On edit command click', ->
    it 'opens command view', ->
      project.addCommand cmd
      view.setContent project, 'Test'
      icon = view.find('.command .icon-pencil')
      expect(icon.length).toBe 1
      icon.click()
      expect(view.activepane).toBe view.commandpane

  describe 'On add dependency click', ->
    it 'opens the dependency view', ->
      button = view.find('#add-dependency-button')
      expect(button.length).toBe 1
      button.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy

  describe 'On import dependency click', ->
    it 'opens the import view', ->
      button = view.find('#import-dependency-button')
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
      view.setContent project, 'Test'
      icon = view.find('.dependency .icon-pencil')
      expect(icon.length).toBe 1
      icon.click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
