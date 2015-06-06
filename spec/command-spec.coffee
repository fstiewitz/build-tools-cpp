{$} = require 'atom-space-pen-views'
CommandView = require '../lib/command-view'
fs = require 'fs'
Projects = require '../lib/projects'
path = require 'path'
temp = require('temp').track()

describe 'Command panel', ->
  [spy, cmd, projects, view, fixturesPath, filename, fd] = []

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
  console.log filename
  fd = res.fd
  fs.writeSync fd, '{}'
  fs.fsyncSync fd

  beforeEach ->
    fixturesPath = atom.project.getPaths()[0]
    projects = new Projects(filename)
    projects.addProject(fixturesPath) if not projects.getProject(fixturesPath)?
    spy = jasmine.createSpy('callback')
    view = new CommandView(spy)
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()
    projects.destroy()

  describe 'When command is created', ->
    it 'opens the command view with default values', ->
      view.show(null, projects.getProject fixturesPath)
      expect(view.nameEditor.getText()).toBe ''
      expect(view.commandEditor.getText()).toBe ''

  describe 'When command view is cancelled', ->
    it 'detaches the command view', ->
      view.show(null, projects.getProject fixturesPath)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      view.find('.btn-error').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      expect(spy).not.toHaveBeenCalled()

  describe 'When command view is confirmed with good values', ->
    it 'calls the callback function', ->
      view.show(null, projects.getProject fixturesPath)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      view.nameEditor.setText('Test command')
      view.commandEditor.setText('foo')
      view.find('.btn-primary').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      expect(spy).toHaveBeenCalledWith(null, {
        name: 'Test command',
        command: 'foo',
        wd: '.',
        shell: false,
        wildcards: false,
        stdout: {
          file: true,
          highlighting: 'nh',
          lint: false
        }
        stderr: {
          file: true,
          highlighting: 'nh',
          lint: false
        }
      })

  describe 'When command view is confirmed with wrong values', ->
    it 'displays an error message and does not call the callback function', ->
      view.show(null, projects.getProject fixturesPath)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      view.nameEditor.setText('Test command')
      view.commandEditor.setText('')
      view.find('.btn-primary').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(spy).not.toHaveBeenCalled()
      expect(view.find('#command-error-none').hasClass('hidden')).toBeFalsy()

  describe 'When command view is created with a preset and confirmed', ->
    it 'displays the preset and calls the callback function on confirm', ->
      view.show(cmd, projects.getProject fixturesPath)
      expect(atom.workspace.getModalPanels()[0].visible).toBeTruthy()
      expect(view.nameEditor.getText()).toBe 'Test command'
      expect(view.commandEditor.getText()).toBe 'pwd "Hello World" test'
      expect(view.wdEditor.getText()).toBe 'sub0'
      expect(view.find('#command_in_shell').prop('checked')).toBeFalsy()
      expect(view.find('#wildcards').prop('checked')).toBeFalsy()
      expect(view.find('#mark_paths_stdout').prop('checked')).toBeFalsy()
      expect(view.find('#stdout #ha').hasClass('selected')).toBeTruthy()
      expect(view.find('#lint_stdout').prop('checked')).toBeFalsy()
      expect(view.find('#mark_paths_stderr').prop('checked')).toBeTruthy()
      expect(view.find('#stderr #hc').hasClass('selected')).toBeTruthy()
      expect(view.find('#lint_stderr').prop('checked')).toBeFalsy()
      view.nameEditor.setText('Test command 2')
      view.commandEditor.setText('foo')
      view.find('.btn-primary').click()
      expect(atom.workspace.getModalPanels()[0].visible).toBeFalsy()
      expect(spy).toHaveBeenCalledWith('Test command', {
        name: 'Test command 2',
        command: 'foo',
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
      })
      projects.watcher.close()
      temp.cleanupSync()
