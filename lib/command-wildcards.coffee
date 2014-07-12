path = require 'path'

module.exports =
  wildcards: {
    "%p": "projectPath",
    "%c": "currentFile",
    "%b": "baseFileName",
    "%f": "currentFolder"
  }

  projectPath: ->
    return atom.project.getPath()

  currentFile: ->
    return atom.workspace.getActiveEditor()?.getPath()

  baseFileName: ->
    return @currentFile().replace(/\.[^/.]+$/,"")

  currentFolder: ->
    return path.dirname(@currentFile())

  replaceWildcards: (command) ->
    k = Object.keys(@wildcards)
    for c in k
      command = command.replace(c, @[@wildcards[c]]())
    return command
