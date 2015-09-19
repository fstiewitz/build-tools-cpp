CommandEditProfilePane = require '../lib/view/command-edit-profile-pane'

{$} = require 'atom-space-pen-views'

describe 'Command Edit Profile Pane', ->
  view = null

  beforeEach ->
    view = new CommandEditProfilePane
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy?()

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  describe 'On set with a value', ->

    beforeEach ->
      view.set {
        stdout:
          highlighting: 'nh'
        stderr:
          highlighting: 'hc'
          profile: 'python'
      }

    it 'sets the fields accordingly', ->
      expect(view.stdout_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stderr_highlights.find('.selected')[0].id).toBe 'hc'
      expect(view.stdout_profile_div.hasClass('hidden')).toBe true
      expect(view.stderr_profile_div.hasClass('hidden')).toBe false
      expect(view.stderr_profile.children()[view.stderr_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue).toBe 'python'

  describe 'On set without a value', ->

    beforeEach ->
      view.set()

    it 'sets the fields to their default values', ->
      expect(view.stdout_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stderr_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stdout_profile_div.hasClass('hidden')).toBe true
      expect(view.stderr_profile_div.hasClass('hidden')).toBe true

  describe 'On get', ->
    c = {}
    r = null

    beforeEach ->
      view.set()
      view.stdout_highlights.find('#ha').click()
      view.stderr_highlights.find('#hc').click()
      r = view.get c

    it 'returns null', ->
      expect(r).toBe null

    it 'updates the command', ->
      expect(c).toEqual {
        stdout:
          highlighting: 'ha'
          profile: undefined
        stderr:
          highlighting: 'hc'
          profile: 'gcc_clang'
      }
