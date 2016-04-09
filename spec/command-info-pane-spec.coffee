CommandInfoPane = require '../lib/view/command-info-pane'
Command = require '../lib/provider/command'

describe 'Command Info Pane', ->
  view = null
  command = null
  up = null
  down = null
  edit = null
  remove = null

  beforeEach ->
    up = jasmine.createSpy('up')
    down = jasmine.createSpy('down')
    edit = jasmine.createSpy('edit')
    remove = jasmine.createSpy('remove')
    command =
      project: atom.project.getPaths()[0]
      oldname: 'Test 1'
      name: 'Test 1'
      command: 'echo test'
      wd: '.'
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'hc'
        profile: 'python'
      output:
        console:
          close_success: true
    command = new Command(command)
    view = new CommandInfoPane(command)
    view.setCallbacks up, down, edit, remove
    jasmine.attachToDOM(view.element)

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  it 'has 4 panes', ->
    expect(view.element.children[1].children.length).toBe 4

  it 'has the correct values', ->
    expect(view.info.find('.module')[0].children[1].children[0].innerText).toBe 'echo test'
    expect(view.info.find('.module')[1].children[1].innerText).toBe 'Display all output streams'
    expect(view.info.find('.module')[2].children[1].innerText).toBe 'Python'
    expect(view.info.find('.panel-heading')[4].innerText).toBe 'Output: Console'

  describe 'On up click', ->

    beforeEach ->
      view.find('.icon-triangle-up').click()

    it 'executes the up callback', ->
      expect(up).toHaveBeenCalled()

  describe 'On down click', ->

    beforeEach ->
      view.find('.icon-triangle-down').click()

    it 'executes the down callback', ->
      expect(down).toHaveBeenCalled()

  describe 'On edit click', ->

    beforeEach ->
      view.find('.icon-pencil').click()

    it 'executes the edit callback', ->
      expect(edit).toHaveBeenCalled()

  describe 'On remove click', ->

    beforeEach ->
      view.find('.icon-x').click()

    it 'executes the remove callback', ->
      expect(remove).toHaveBeenCalled()
