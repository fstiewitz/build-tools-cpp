CommandEditSavePane = require '../lib/view/command-edit-save-pane'

describe 'Command Edit Save Pane', ->
  view = null

  beforeEach ->
    view = new CommandEditSavePane

  afterEach ->
    view.destroy?()

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  describe 'On set with a value', ->

    beforeEach ->
      view.set {
        save_all: false
      }

    it 'sets the fields accordingly', ->
      expect(view.find('#save').prop('checked')).toBe false

  describe 'On set without a value', ->

    beforeEach ->
      view.set()

    it 'sets the fields to their default values', ->
      expect(view.find('#save').prop('checked')).toBe true

  describe 'On get', ->
    c = {}
    r = null

    beforeEach ->
      view.find('#save').prop('checked', false)
      r = view.get c

    it 'returns null', ->
      expect(r).toBe null

    it 'updates the command', ->
      expect(c).toEqual {
        save_all: false
      }
