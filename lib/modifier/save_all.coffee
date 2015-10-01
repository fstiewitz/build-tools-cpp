module.exports =

  name: 'Save All'
  description: 'Save all modified files before executing the command(s)'
  private: false

  edit:
    class SaveAllSaver
      get: (command) ->
        command.modifier.save_all = {}
        return null

  in: ->
    for editor in atom.workspace.getTextEditors()
      editor.save() if editor.isModified() and editor.getPath()?
    return
