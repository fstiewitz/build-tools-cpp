Command = require './command'
Dependency = require './dependency'

module.exports =
  class Project
    path: ''
    commands: []
    dependencies: []
    save: null
    check: null

    constructor: (@path,{commands,dependencies},@save,@check) ->
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
        @save()
      else
        atom.notifications?.addError "Command \"#{item.name}\" already exists"

    addDependency: (item) ->
      item.from.project = @path
      @dependencies.push(new Dependency(item))
      @save()

    removeCommand: (name) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i,1)
        @save()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    removeDependency: (id) ->
      @dependencies.splice(id,1)
      @save()

    removeDependencies: ({project,command}) ->
      new_dependencies = []
      for dependency in @dependencies
        if not (dependency.to.project is project and dependency.to.command is command)
          new_dependencies.push(dependency)
      @dependencies = new_dependencies


    replaceCommand: (oldname, item) ->
      if (i = @getCommandIndex oldname) isnt -1
        item['project'] = @path
        @commands.splice(i,1,new Command(item))
        @save()
      else
        atom.notifications?.addError "Command \"#{oldname}\" not found"

    replaceDependency: (oldid, item) ->
      item.from.project = @path
      @dependencies.splice(oldid, 1, new Dependency(item,errors))
      @save()

    moveCommand: (name, offset) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i+offset,0,@commands.splice(i,1)[0])
        @save()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    moveDependency: (id, offset) ->
      @dependencies.splice(id+offset,0,@dependencies.splice(id,1)[0])
      @save()

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
