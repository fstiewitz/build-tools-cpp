ll = require '../linter-list'

coordinates = {}

module.exports =
  output:
    class Linter

      newQueue: (@queue) ->
        ll.messages = []
        coordinates = {}

      stdout:
        linter: (message) ->
          return ll.messages.push message if atom.inSpecMode()
          return if coordinates[message.filePath + ':' + message.range[0][0]]?
          coordinates[message.filePath + ':' + message.range[0][0]] = true
          ll.messages.push message

      stderr:
        linter: (message) ->
          return ll.messages.push message if atom.inSpecMode()
          return if coordinates[message.filePath + ':' + message.range[0][0]]?
          coordinates[message.filePath + ':' + message.range[0][0]] = true
          ll.messages.push message

      exitQueue: (code) ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'linter:lint')
