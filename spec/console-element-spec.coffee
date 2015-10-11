Model = require '../lib/console/console'
View = require '../lib/console/console-element'

describe 'Output Module - Console Element', ->
  [model, view, tab] = []

  beforeEach ->
    model = new Model()
    view = new View(model)
    view.show = jasmine.createSpy('show')
    view.hide = jasmine.createSpy('hide')
    tab = model.getTab(project: 'foo', name: 'bar')
    tab.focus()
    jasmine.attachToDOM(view.element)

  afterEach ->
    model.destroy()
    view.detach()

  it 'has an active tab', ->
    expect(view.tabs.children()[0]).toEqual tab.header[0]
    expect(view.output.children()[0]).toEqual tab.view[0]
    expect(view.name.text()).toBe 'bar of foo'

  describe 'when clicking the close button', ->
    it 'closes the view', ->
      view.find('.icon-x').click()
      expect(view.hide).toHaveBeenCalled()

  describe 'when adding another tab', ->
    tab2 = null

    beforeEach ->
      tab2 = model.getTab(project: 'foo', name: 'bar2')

    it 'adds a new tab header', ->
      expect(view.tabs.children()[1]).toEqual tab2.header[0]

    describe 'when clicking on the header', ->

      beforeEach ->
        tab2.header.find('.name').click()

      it 'focuses the new tab', ->
        expect(view.active).toBe tab2
        expect(view.name.text()).toBe 'bar2 of foo'

      it 'highlights the new tab', ->
        expect(view.tabs.children()[1].classList.contains 'active').toBe true

    describe 'when removing the new tab', ->

      beforeEach ->
        tab2.focus()
        tab2.header.find('.close').click()

      it 'focuses the old tab', ->
        expect(view.tabs.children().length).toBe 1
        expect(view.output.children()[0]).toEqual tab.view[0]
        expect(view.active).toBe tab
