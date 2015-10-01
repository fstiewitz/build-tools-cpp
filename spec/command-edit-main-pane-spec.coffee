CommandEditMainPane = require '../lib/view/command-edit-main-pane'

describe 'Command Edit Main Pane', ->
  view = null

  beforeEach ->
    view = new CommandEditMainPane

  afterEach ->
    view.destroy?()

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  describe 'On set with a value', ->

    beforeEach ->
      view.set {
        name: 'Test'
        command: 'echo test'
        wd: '.'
        shell: true
        wildcards: false
      }

    it 'sets the fields accordingly', ->
      expect(view.command_name.getModel().getText()).toBe 'Test'
      expect(view.command_text.getModel().getText()).toBe 'echo test'
      expect(view.working_directory.getModel().getText()).toBe '.'

  describe 'On set without a value', ->

    beforeEach ->
      view.set()

    it 'sets the fields to their default values', ->
      expect(view.command_name.getModel().getText()).toBe ''
      expect(view.command_text.getModel().getText()).toBe ''
      expect(view.working_directory.getModel().getText()).toBe '.'

  describe 'On get with wrong values', ->
    c = {}
    r = null

    beforeEach ->
      r = view.get c

    it 'returns an error', ->
      expect(r).toBe 'Empty Name'

    it 'does not update the command', ->
      expect(c).toEqual {}

  describe 'On get with correct values', ->
    c = {}
    r = null

    beforeEach ->
      view.command_name.getModel().setText 'Foo'
      view.command_text.getModel().setText 'Bar'
      r = view.get c

    it 'returns null', ->
      expect(r).toBe null

    it 'updates the command', ->
      expect(c).toEqual {
        name: 'Foo'
        command: 'Bar'
        wd: '.'
      }
