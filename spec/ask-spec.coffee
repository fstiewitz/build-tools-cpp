AskView = require '../lib/ask-view'

describe 'Ask Panel', ->
  [spy, view] = []

  beforeEach ->
    spy = jasmine.createSpy('callback')
    view = new AskView
    view.show 'Command', spy
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy()

  describe 'After initialization', ->
    it 'shows the command', ->
      expect(view.Command.getText()).toBe 'Command'
    it 'hides the error field', ->
      expect(view.find('.error').hasClass('hidden')).toBe true

  describe 'When accepting with valid data', ->

    beforeEach ->
      view.Command.setText('Command something')
      view.find('.icon-check').click()

    it 'calls the callback with the new command', ->
      expect(spy).toHaveBeenCalledWith 'Command something'

  describe 'When accepting with invalid data', ->

    beforeEach ->
      view.Command.setText('')
      view.find('.icon-check').click()

    it 'shows the error and does not call the callback function', ->
      expect(spy).not.toHaveBeenCalled()
      expect(view.find('.error').hasClass('hidden')).toBe false
