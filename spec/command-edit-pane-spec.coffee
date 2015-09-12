CommandEditPane = require '../lib/view/command-edit-pane'
Command = require '../lib/command'

describe 'Command Edit Pane', ->
  view = null
  accept = null
  cancel = null
  command = null

  beforeEach ->
    accept = jasmine.createSpy('accept')
    cancel = jasmine.createSpy('cancel')
    command =
      project: atom.project.getPaths()[0]
      oldname: 'Test 1'
      name: 'Test 1'
      command: 'echo test'
      wd: '.'
      shell: false
      wildcards: false
      save_all: true
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'hc'
        profile: 'python'
      output:
        console:
          close_success: true
    view = new CommandEditPane(command)
    view.setCallbacks accept, cancel
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  it 'has 5 edit panes', ->
    expect(view.find('.inset-panel').length).toBe 5

  it 'has the correct values', ->
    expect(view.panes[0].view.command_name.getModel().getText()).toBe 'Test 1'
    expect(view.panes[1].view.find('#save').prop('checked')).toBe true
    expect(view.panes[2].view.stderr_profile[0].selectedIndex).toBe 3
    expect(view.panes[3].view.find('#close_success').prop('checked')).toBe true
    expect(view.panes[3].pane.find('input').prop('checked')).toBe true
    expect(view.panes[3].pane.find('input')[0].id).toBe 'console'
    expect(view.panes[4].view).toBeNull()
    expect(view.panes[4].pane.find('input').prop('checked')).toBe false
    expect(view.panes[4].pane.find('input')[0].id).toBe 'linter'

  describe 'On accept', ->

    beforeEach ->
      view.panes[1].view.find('#save').prop('checked', false)
      view.find('.btn-primary').click()

    it 'returns the correct values', ->
      res = accept.mostRecentCall.args[0]
      expect(accept).toHaveBeenCalled()
      expect(res.oldname).toBe 'Test 1'
      expect(res.project).toBe atom.project.getPaths()[0]
      expect(res.command).toBe 'echo test'
      expect(res.save_all).toBe false
      expect(res.stdout.highlighting).toBe 'nh'
      expect(res.stderr.highlighting).toBe 'hc'
      expect(res.stderr.profile).toBe 'python'
      expect(res.output.console.close_success).toBe true
      expect(res.output.linter).toBeUndefined()

    it 'calls the cancel callback', ->
      expect(cancel).toHaveBeenCalled()

  describe 'Pane can be created with atom.views.getView', ->
    [c, p] = []

    execute = (callback) ->
      waitsForPromise -> atom.packages.activatePackage('build-tools')
      runs -> callback()

    afterEach ->
      p.destroy()

    it 'On getView with default command', ->
      execute ->
        c = new Command
        p = atom.views.getView(c)
        expect(p.panes[0].view.command_name.getModel().getText()).toBe ''
        expect(p.command.oldname).toBeUndefined()

    it 'on getView with a valid command', ->
      execute ->
        command.oldname = undefined
        c = new Command(command)
        p = atom.views.getView(c)
        expect(p.panes[0].view.command_name.getModel().getText()).toBe 'Test 1'
        expect(p.command.oldname).toBe 'Test 1'
