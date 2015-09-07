Module = require '../lib/output/console'

describe 'Output Module - Console', ->
  module = null

  beforeEach ->
    module = new Module.output
    q = [1, 2, 3]
    module.newQueue(queue: q)
    q.splice(0, 1)
    module.newCommand name: 'Test command', project: 'fixtures'

  afterEach ->
    Module.deactivate()

  it 'sets the header line', ->
    expect(module.getView().name.text()).toBe 'Test command of fixtures'

  it 'sets the progress bar', ->
    expect(module.getView().progress.prop('max')).toBe 3

  describe 'On stdout input', ->

    beforeEach ->
      module.stdout.in input: 'Foo Bar', files: []
      module.stdout.in input: 'Hello World', files: []

    it 'adds the line to the internal line stack', ->
      expect(module.stdout.lines.length).toBe 2
      expect(module.stdout.lines[1].innerText).toBe 'Hello World'

    describe 'On setType', ->

      beforeEach ->
        module.stdout.setType 'warning'

      it 'changes the message type', ->
        expect(module.stdout.lines[1].classList.contains 'text-warning').toBe true

    describe 'On print', ->

      beforeEach ->
        module.stdout.print input: {input: 'Hello World!', type: 'warning'}, files: []

      it 'changes the message type', ->
        expect(module.stdout.lines[1].classList.contains 'text-warning').toBe true

      it 'changes the message content', ->
        expect(module.stdout.lines[1].innerText).toBe 'Hello World!'

    describe 'On replacePrevious', ->

      beforeEach ->
        input = [
          {input: {input: 'Hello World!', type: 'warning'}, files: []}
          {input: {input: 'Goodbye World!', type: 'warning'}, files: []}
        ]
        module.stdout.replacePrevious input

      it 'changes the first line\'s type', ->
        expect(module.stdout.lines[0].classList.contains 'text-warning').toBe true

      it 'changes the first line\'s content', ->
        expect(module.stdout.lines[0].innerText).toBe 'Hello World!'

      it 'changes the second line\'s type', ->
        expect(module.stdout.lines[1].classList.contains 'text-warning').toBe true

      it 'changes the second line\'s content', ->
        expect(module.stdout.lines[1].innerText).toBe 'Goodbye World!'

  describe 'On stderr input', ->

    beforeEach ->
      module.stderr.in input: 'Foo Bar', files: []
      module.stderr.in input: 'Hello World', files: []

    it 'adds the line to the internal line stack', ->
      expect(module.stderr.lines.length).toBe 2
      expect(module.stderr.lines[1].innerText).toBe 'Hello World'

    describe 'On setType', ->

      beforeEach ->
        module.stderr.setType 'warning'

      it 'changes the message type', ->
        expect(module.stderr.lines[1].classList.contains 'text-warning').toBe true

    describe 'On print', ->

      beforeEach ->
        module.stderr.print input: {input: 'Hello World!', type: 'warning'}, files: []

      it 'changes the message type', ->
        expect(module.stderr.lines[1].classList.contains 'text-warning').toBe true

      it 'changes the message content', ->
        expect(module.stderr.lines[1].innerText).toBe 'Hello World!'

    describe 'On replacePrevious', ->

      beforeEach ->
        input = [
          {input: {input: 'Hello World!', type: 'warning'}, files: []}
          {input: {input: 'Goodbye World!', type: 'warning'}, files: []}
        ]
        module.stderr.replacePrevious input

      it 'changes the first line\'s type', ->
        expect(module.stderr.lines[0].classList.contains 'text-warning').toBe true

      it 'changes the first line\'s content', ->
        expect(module.stderr.lines[0].innerText).toBe 'Hello World!'

      it 'changes the second line\'s type', ->
        expect(module.stderr.lines[1].classList.contains 'text-warning').toBe true

      it 'changes the second line\'s content', ->
        expect(module.stderr.lines[1].innerText).toBe 'Goodbye World!'

  describe 'On error', ->

    beforeEach ->
      module.error 'Error'

    it 'shows the error message', ->
      expect(module.getView().name.text()).toBe 'Test command of fixtures: received Error'

  describe 'On exitCommand with successful exit code', ->

    beforeEach ->
      module.exitCommand 0

    it 'sets the header line', ->
      expect(module.getView().name.text()).toBe 'Test command of fixtures: finished with exitcode 0'

    it 'sets the progress bar', ->
      expect(module.getView().progress.prop('value')).toBe 1

  describe 'On exitCommand with error code', ->

    beforeEach ->
      module.exitCommand 1

    it 'sets the header line', ->
      expect(module.getView().name.text()).toBe 'Test command of fixtures: finished with exitcode 1'

    it 'sets the progress bar', ->
      expect(module.getView().progress.prop('value')).toBe 0
