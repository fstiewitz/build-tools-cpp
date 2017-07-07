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
    p = []
    for editor in atom.workspace.getTextEditors()
      if editor.isModified() and editor.getPath()?
        p.push editor.save()
    return Promise.all(p)
