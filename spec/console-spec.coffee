path = require 'path'
ConsoleOutput = require '../lib/console'

describe 'Console View', ->
  [view, fixturesPath, data, input_stdout, input_stderr] = []

  data = {}
  input_stdout = [
    'test output',
    '../src/test.c:3',
    'test.c: 2: error: Something'
  ]
  input_stderr = [
    'stderr test',
    '../src/test.c:4:2: error: Something',
    'foo',
    '^',
    'stderr'
  ]

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

  describe 'Output', ->

    describe 'When :createOutput', ->
      it 'creates output objects', ->
        data['path'] = fixturesPath
        expect(view.Output).toBeUndefined()
        expect(view.stdout).toBeUndefined()
        expect(view.stderr).toBeUndefined()
        view.createOutput data
        expect(view.Output).toBeDefined()
        expect(view.stdout).toBeDefined()
        expect(view.stderr).toBeDefined()

    describe 'On input', ->
      it 'correctly displays errors and warnings', ->
        view.createOutput data
        expect(view.Output).toBeDefined()
        expect(view.stdout).toBeDefined()
        expect(view.stderr).toBeDefined()
        for i in [0..2]
          view.stdout.in input_stdout[i]
        for i in [0..4]
          view.stderr.in input_stderr[i]
        content = view.find('.output').children()
        expect(content.length).toBe 8
        expect(content[0].classList.contains('text-warning')).toBeTruthy()
        expect(content[1].classList.contains('text-warning')).toBeTruthy()
        expect(content[2].classList.contains('text-warning')).toBeTruthy()
        expect(content[3].classList.contains('text-error')).toBeTruthy()
        expect(content[4].classList.contains('text-error')).toBeTruthy()
        expect(content[5].classList.contains('text-error')).toBeTruthy()
        expect(content[6].classList.contains('text-error')).toBeTruthy()
        expect(content[7].classList.contains('text-error')).toBeFalsy()
        expect(content[1].children[0].innerHTML).toBe '../src/test.c:3'
        link = content[4].children[1]
        expect(link.classList.contains('filelink')).toBeTruthy()
        expect(link.attributes['name'].value).toBe path.join(fixturesPath, 'src', 'test.c')
        expect(link.attributes['row'].value).toBe '4'
        expect(link.attributes['col'].value).toBe '2'
        expect(link.innerHTML).toBe '../src/test.c:4:2'

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
