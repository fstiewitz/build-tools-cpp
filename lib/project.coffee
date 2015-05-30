Command = require './command'

module.exports =
  class Project
    path: ''
    commands: []
    dependencies: []
    cb: null

    constructor: (@path,{commands,@dependencies},@cb) ->
      @commands = []
      for command in commands
        @commands.push(new Command(command))
      return

    addCommand: (item) ->
      if @getCommandIndex(item.name) is -1
        item['project'] = @path
        @commands.push(new Command(item))
        @cb()
      else
        atom.notifications?.addError "Command \"#{item.name}\" already exists"

    removeCommand: (name) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i,1)
        @cb()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    replaceCommand: (oldname, item) ->
      if (i = @getCommandIndex oldname) isnt -1
        item['project'] = @path
        @commands[i] = new Command(item)
        @cb()
      else
        atom.notifications?.addError "Command \"#{oldname}\" not found"

    moveCommand: (name, offset) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i+offset,0,@commands.splice(i,1)[0])
        @cb()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    hasCommand: (name) ->
      return (@getCommandIndex name isnt -1)

    getCommandIndex: (name) ->
      for cmd, index in @commands
        if cmd.name is name
          return index
      return -1

    getCommandByIndex: (id) ->
      @commands[id]

    getCommand: (name) ->
      @commands[id] if (id=@getCommandIndex name) isnt -1
