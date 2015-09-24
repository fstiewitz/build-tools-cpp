module.exports =
  in: ->
    for editor in atom.workspace.getTextEditors()
      editor.save() if editor.isModified() and editor.getPath()?
    return
