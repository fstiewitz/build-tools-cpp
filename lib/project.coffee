Command = require './command'
Dependency = require './dependency'

module.exports =
  class Project
    path: ''
    commands: []
    dependencies: []
    cb: null

    constructor: (@path,{commands,dependencies},@cb) ->
      @commands = []
      for command in commands
        @commands.push(new Command(command))
      @dependencies = []
      for dependency in dependencies
        @dependencies.push(new Dependency(dependency))
      return

    addCommand: (item) ->
      if @getCommandIndex(item.name) is -1
        item['project'] = @path
        @commands.push(new Command(item))
        @cb()
      else
        atom.notifications?.addError "Command \"#{item.name}\" already exists"

    addDependency: (item) ->
      @dependencies.push(new Dependency(item))
      @cb()

    removeCommand: (name) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i,1)
        @cb()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    removeDependency: (id) ->
      @dependencies.splice(id,1)
      @cb()

    replaceCommand: (oldname, item) ->
      if (i = @getCommandIndex oldname) isnt -1
        item['project'] = @path
        @commands[i] = new Command(item)
        @cb()
      else
        atom.notifications?.addError "Command \"#{oldname}\" not found"

    replaceDependency: (oldid, item) ->
      @dependencies[oldid] = new Dependency(item)
      @cb()

    moveCommand: (name, offset) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i+offset,0,@commands.splice(i,1)[0])
        @cb()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    moveDependency: (id, offset) ->
      @dependencies.splice(id+offset,0,@dependencies.splice(id,1)[0])
      @cb()

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
