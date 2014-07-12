path = require 'path'

module.exports =
  wildcards: {
    "%p": "projectPath",
    "%c": "currentFile",
    "%b": "baseFileName",
    "%f": "currentFolder"
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

  replaceWildcards: (command, root) ->
    k = Object.keys(@wildcards)
    for c in k
      command = command.replace(c, @[@wildcards[c]](path.resolve(@projectPath(),root)))
    return command
