ll = require '../linter-list'

module.exports =
  output:
    class Linter

      newQueue: (@queue) ->
        ll.messages = []

      stdout:
        linter: (message) ->
          ll.messages.push message

      stderr:
        linter: (message) ->
          ll.messages.push message

      exitQueue: (code) ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'linter:lint')
