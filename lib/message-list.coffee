module.exports =
  settings: null

  commands: {}

  addCommand: (item) ->
    @commands[item.name] = item.command
    return

  editCommand: (item) ->
    delete @commands[item.oldname]
    @addCommand(item)
    return

  removeCommand: (item) ->
    delete @commands[item]
    return

  messages: {}
