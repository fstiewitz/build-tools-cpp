path = require 'path'
ConsoleOutput = require '../lib/console'

describe 'Console View', ->
  [view, fixturesPath, data, input_stdout, input_stderr] = []

  beforeEach ->
    activationPromise = atom.packages.activatePackage('language-c')
    waitsForPromise -> activationPromise

    view = new ConsoleOutput()
    view.showBox()
    jasmine.attachToDOM(view.element)
    expect(view.hasClass('console')).toBeTruthy()
    expect(view.find('.output').hasClass('hidden')).toBeTruthy()
    fixturesPath = atom.project.getPaths()[0]
    data = {
      project: fixturesPath
      name: 'Test command',
      command: 'echo "Test"',
      wd: 'build',
      shell: false,
      wildcards: false,
      close_success: false
      stdout: {
        file: false,
        highlighting: 'ha',
        lint: false
      }
      stderr: {
        file: true,
        highlighting: 'hc',
        profile: 'gcc_clang',
        lint: false
      }
    }

  afterEach ->
    view.destroy()

  describe 'When :setHeader', ->
    it 'sets the header', ->
      expect(view.find('.name').html()).toBe ''
      view.setHeader 'Test'
      expect(view.find('.name').html()).toBe 'Test'

  describe 'When :printLine', ->
    it 'prints a line', ->
      expect(view.find('.output').html()).toBe ''
      expect(view.find('.output').hasClass('hidden')).toBeTruthy()
      view.printLine 'Test'
      expect(view.find('.output').html()).toBe 'Test'
      expect(view.find('.output').hasClass('hidden')).toBeFalsy()

  describe 'Timeout', ->

    beforeEach ->
      view.printLine 'Test'
      atom.config.set('build-tools.CloseOnSuccess', 3)

    describe 'When timeout is disabled', ->
      it 'does not close the console pane on success', ->
        view.cmd = close_success: false
        view.finishConsole(0)
        expect(view.visible_items.header).toBeTruthy()

    describe 'When timeout is enabled (0)', ->
      it 'closes the console pane on success', ->
        atom.config.set('build-tools.CloseOnSuccess', 0)
        view.cmd = close_success: true
        view.finishConsole(0)
        expect(view.visible_items.header).toBeFalsy()

    describe 'When command fails', ->
      it 'does not close the console pane', ->
        view.cmd = close_success: true
        view.finishConsole(1)
        expect(view.visible_items.header).toBeTruthy()

  describe 'When single command is executed', ->
    beforeEach ->
      view.setQueueCount 1

    it 'creates an indeterminate progress bar', ->
      expect(view.progress.attr('value')).not.toBeDefined()

    describe 'and fails', ->
      it 'shows an empty progress bar', ->
        view.setQueueCount(0)
        expect(view.progress.attr('value')).toBe '0'

    describe 'and succeeds', ->
      it 'shows a full progress bar', ->
        view.setQueueLength(0)
        expect(view.progress.attr('value')).toBe '1'

  describe 'When two commands are executed', ->
    beforeEach ->
      view.setQueueCount 2

    it 'creates a determinate progress bar', ->
      expect(view.progress.attr('value')).toBe '0'
      expect(view.progress.attr('max')).toBe '2'

    describe 'and the first command fails', ->
      it 'shows an empty progress bar', ->
        view.setQueueLength(2)
        expect(view.progress.attr('value')).toBe '0'

    describe 'and the second command fails', ->
      it 'shows a 50% progress bar', ->
        view.setQueueLength(1)
        expect(view.progress.attr('value')).toBe '1'

    describe 'and both commands succeed', ->
      it 'shows a full progress bar', ->
        view.setQueueLength(0)
        expect(view.progress.attr('value')).toBe '2'
