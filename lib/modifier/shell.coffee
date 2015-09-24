Command = null

module.exports =

  activate: ->
    Command = require '../provider/command'

  deactivate: ->
    Command = null

  postSplit: (command) ->
    args = Command.splitQuotes command.modifier.command.shell.command
    command.args = args.slice(1).concat([command.command]).concat(command.args)
    command.command = args[0]
    return
