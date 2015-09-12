SaveInfoPane = require '../lib/view/command-info-save-pane'

describe 'Command Info Save Pane', ->
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
      stderr:
        highlighting: 'hc'
        profile: 'python'
      output:
        console:
          close_success: true

    view = new SaveInfoPane(command)

  it 'has an element', ->
    expect(view.element).toBeDefined()

  it 'has all values', ->
    expect(view.element.children[1].children[0].innerText).toBe 'true'
