Console = require '../lib/console/console'

describe 'Output Module - Console', ->
  model = null
  tab = null
  [focus, create, remove] = []

  beforeEach ->
    model = new Console
    focus = jasmine.createSpy('focus')
    create = jasmine.createSpy('create')
    remove = jasmine.createSpy('remove')
    model.onFocusTab focus
    model.onCreateTab create
    model.onRemoveTab remove
    tab = model.getTab(project: 'foo', name: 'bar')

  afterEach ->
    model.destroy()

  it 'adds a tab', ->
    expect(model.tabs['foo']['bar']).toBeDefined()

  it 'calls the create callback', ->
    expect(create).toHaveBeenCalled()

  it 'returns the same tab for the same command', ->
    expect(model.getTab(project: 'foo', name: 'bar')).toEqual tab

  describe 'on focus', ->

    beforeEach ->
      tab.focus()

    it 'emits the focus event', ->
      expect(focus).toHaveBeenCalledWith(tab)

  describe 'when close icon is clicked', ->

    beforeEach ->
      tab.header.find('.close').click()

    it 'removes the tab', ->
      expect(model.tabs['foo']['bar']).toBeUndefined()

    it 'calls the remove callback', ->
      expect(remove).toHaveBeenCalledWith(tab)
