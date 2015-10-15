SaveAll = require '../lib/modifier/save_all'
path = require 'path'

describe 'Queue Modifier - Save All', ->
  editor = null

  beforeEach ->
    jasmine.attachToDOM(atom.views.getView(atom.workspace))
    p = atom.workspace.open(path.join(atom.project.getPaths()[0], 'test.vhd'))
    p.then (e) -> editor = e
    waitsForPromise -> p
    runs ->
      editor.insertText('hello')
      spyOn(editor, 'save')
      SaveAll.in()

  it 'saves all modified buffers', ->
    expect(editor.save).toHaveBeenCalled()
