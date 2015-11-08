ProfileInfoPane = require '../lib/view/command-info-profile-pane'

describe 'Command Info Profile Pane', ->
  view = null
  command = null

  beforeEach ->
    command =
      project: atom.project.getPaths()[0]
      oldname: 'Test 1'
      name: 'Test 1'
      command: 'echo test'
      wd: '.'
      shell: false
      wildcards: true
      save_all: true
      stdout:
        highlighting: 'nh'
        ansi_option: 'parse'
      stderr:
        highlighting: 'hc'
        profile: 'python'
      output:
        console:
          close_success: true

    view = new ProfileInfoPane(command)

  it 'has an element', ->
    expect(view.element).toBeDefined()

  it 'has all values', ->
    expect(view.element.children[1].children[0].innerText).toBe 'No highlighting - Parse ANSI Color Codes'
    expect(view.element.children[1].children[1].innerText).toBe 'Python'
