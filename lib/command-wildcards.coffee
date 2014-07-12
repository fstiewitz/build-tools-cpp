path = require 'path'

module.exports =
  wildcards: {
    "p": "projectPath",
    "c": "currentFile",
    "b": "baseFileName",
    "f": "currentFolder",
    "n": "filename"
  }

  projectPath: (root) ->
    return atom.project.getPath()

  currentFile: (root) ->
    return path.relative(root, atom.workspace.getActiveEditor()?.getPath())

  baseFileName: (root) ->
    current = @currentFile(root)
    return current.replace(path.extname(current),"")

  currentFolder: (root) ->
    return path.dirname(@currentFile(root))

  filename: (root) ->
    current = atom.workspace.getActiveEditor()?.getPath()
    return path.basename(current, path.extname(current))

  replaceWildcards: (command, root) ->
    if /%[g]?[pcbnf]{1}/.test(command)
      k = Object.keys(@wildcards)
      resroot = path.resolve(@projectPath(),root)
      for c in k
        if new RegExp("%[g]?"+c+"{1}").test(command)
          result = @[@wildcards[c]](resroot)
          command = command.replace(new RegExp("%" + c,"g"), result)
          command = command.replace(new RegExp("%" + "g" + c,"g"), path.resolve(root, result))
    return command
