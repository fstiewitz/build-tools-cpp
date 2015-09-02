ll = require '../linter-list'

module.exports =
  output:
    class Linter
      setInstance: (@instance) ->

      newQueue: (@queue) ->
        ll.messages = []

      message: (message) ->
        ll.messages.push message

      exitQueue: (code) ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'linter:lint')
        @instance.dispose()
