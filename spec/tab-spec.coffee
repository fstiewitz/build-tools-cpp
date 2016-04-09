Tab = require '../lib/console/tab'

describe 'Console - Tab', ->
  [command, tab] = []

  beforeEach ->
    command =
      project: atom.project.getPaths()[0]
      name: 'Test Command'
      command: 'test'
      wd: '.'
      output:
        console:
          close_success: true
    atom.config.set('build-tools.CloseOnSuccess', 0)
    tab = new Tab(command)

  afterEach ->
    tab.destroy()

  describe 'On ::clear', ->

    beforeEach ->
      spyOn(tab.view, 'clear').andCallThrough()
      tab.clear()

    it 'clears the return variables', ->
      expect(tab.error).toBeNull()
      expect(tab.code).toBeNull()

    it 'calls view::clear', ->
      expect(tab.view.clear).toHaveBeenCalled()

  describe 'On ::setRunning', ->
    it 'sets the tab header to "running"', ->
      tab.setRunning()
      expect(tab.header.icon[0].className).toBe 'icon icon-sync'

  describe 'On ::setError', ->

    beforeEach ->
      tab.setError 'Error'

    it 'sets the tab header to "error"', ->
      expect(tab.header.icon[0].classList.contains 'icon-x').toBe true

    it 'sets the error variable', ->
      expect(tab.error).toBe 'Error'
      expect(tab.code).toBe -1

  describe 'On ::setFinished', ->
    spy = null

    beforeEach ->
      spy = jasmine.createSpy 'close'
      tab.emitter.on 'close', spy
      tab.setFinished exitcode: 0, signal: null

    it 'sets the tab header to "error"', ->
      expect(tab.header.icon[0].classList.contains 'icon-check').toBe true

    it 'sets the error variable', ->
      expect(tab.code).toBe 0

  describe 'On ::setCancelled', ->

    beforeEach ->
      tab.setCancelled()

    it 'sets the tab header to "error"', ->
      expect(tab.header.icon[0].classList.contains 'icon-x').toBe true

    it 'sets the error variable', ->
      expect(tab.code).toBe -2
