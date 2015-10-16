Main = require '../lib/main'

describe 'Console Service', ->
  model = null
  [focus, create, remove] = []

  beforeEach ->
    Main.provideInput().OutputModules.reset()
    jasmine.attachToDOM(atom.views.getView(atom.workspace))
    spyOn(Main.provideInput().OutputModules.modules.console, 'activate').andCallThrough()
    model = Main.provideConsole()
    focus = jasmine.createSpy('focus')
    create = jasmine.createSpy('create')
    remove = jasmine.createSpy('remove')
    model.onFocusTab focus
    model.onCreateTab create
    model.onRemoveTab remove

  afterEach ->
    Main.provideInput().OutputModules.deactivate('console')

  it 'initializes the console', ->
    expect(Main.provideInput().OutputModules.modules.console.activate).toHaveBeenCalled()
    expect(model).toBeDefined()

  describe 'when creating a new tab', ->
    tab = null
    close = null

    beforeEach ->
      tab = model.createCustomTab 'Test Tab'
      close = jasmine.createSpy('close')
      tab.onClose close

    it 'emits a create event', ->
      expect(create).toHaveBeenCalledWith tab

    describe 'on clear', ->
      it 'clears the view', ->
        tab.view.text('Hello')
        expect(tab.view.text()).toBe 'Hello'
        tab.clear()
        expect(tab.view.text()).toBe ''

    describe 'on setIcon', ->
      it 'sets the icon', ->
        tab.setIcon 'x'
        expect(tab.header.icon.hasClass('icon-x')).toBe true

    describe 'on setHeader', ->
      it 'sets the header', ->
        tab.setHeader 'Hello'
        expect(tab.header.name.text()).toBe 'Hello'
        expect(tab.title.innerText).toBe 'Hello'

    describe 'on printLine', ->
      it 'prints a line', ->
        tab.printLine('<div>Hello World!</div>')
        expect(tab.view.text()).toBe 'Hello World!'

    describe 'on focus', ->

      beforeEach ->
        tab.focus()

      it 'calls the focus event', ->
        expect(focus).toHaveBeenCalledWith tab
        expect(model.activeTab).toBe tab

    describe 'on close', ->

      beforeEach ->
        tab.close()

      it 'calls the close event', ->
        expect(close).toHaveBeenCalled()

      it 'calls the remove event', ->
        expect(remove).toHaveBeenCalledWith tab
