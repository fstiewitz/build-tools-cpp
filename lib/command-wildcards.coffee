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
    current = @currentFile(root)
    return path.basename(current, path.extname(current))

  replaceWildcards: (command, root) ->
    k = Object.keys(@wildcards)
    for c in k
      command = command.replace(new RegExp("%" + c,"g"), @[@wildcards[c]](path.resolve(@projectPath(),root)))
      command = command.replace(new RegExp("%" + "g" + c,"g"), path.resolve(root, @[@wildcards[c]](path.resolve(@projectPath(),root))))
    return command
