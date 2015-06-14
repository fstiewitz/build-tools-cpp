Command = require './command'
Dependency = require './dependency'

module.exports =
  class Project
    path: ''
    commands: []
    dependencies: []
    save: null
    check: null
    key: {}

    constructor: (@path,{commands,dependencies,key},@save,@check) ->
      if key?
        @key = key
      else
        @key =
          make: null
          configure: null
          preconfigure: null
      @commands = []
      for command in commands
        @commands.push(new Command(command))
      @dependencies = []
      for dependency in dependencies
        @dependencies.push(new Dependency(dependency))
      return

    notify: (message) ->
      atom.notifications?.addError message
      console.log('build-tools-cpp: ' + message)

    setKey: (key, command) ->
      @key[key] = command
      @check(added: {
        key: @path,
        command
        })
      @save()

    clearKey: (key) ->
      if @key[key]?
        @key[key] = null
        @save()

    addCommand: (item) ->
      if @getCommandIndex(item.name) is -1
        item['project'] = @path
        @commands.push(new Command(item))
        @save()
      else
        @notify "Command \"#{item.name}\" already exists"

    addDependency: (item) ->
      item.from['project'] = @path
      @dependencies.push(new Dependency(item))
      @check(added: item)
      @save()

    removeCommand: (name) ->
      if (i = @getCommandIndex name) isnt -1
        @check(removed: @commands.splice(i,1)[0])
        @save()
      else
        @notify "Command \"#{name}\" not found"

    removeDependency: (id) ->
      @check(removed: @dependencies.splice(id,1)[0])
      @save()

    replaceCommand: (oldname, item) ->
      if (i = @getCommandIndex oldname) isnt -1
        item['project'] = @path
        if oldname is item.name
          @commands.splice(i,1,new Command(item))
        else
          @check(replaced:
            old: @commands.splice(i,1)[0]
            new: item
            )
          @commands.splice(i,0,new Command(item))
        @save()
      else
        @notify "Command \"#{oldname}\" not found"

    replaceDependency: (oldid, item) ->
      item.from['project'] = @path
      @check(
        removed: @dependencies.splice(oldid,1)[0]
        added: item
      )
      @dependencies.splice(oldid, 0, new Dependency(item))
      @save()

    moveCommand: (name, offset) ->
      if (i = @getCommandIndex name) isnt -1
        @commands.splice(i+offset,0,@commands.splice(i,1)[0])
        @save()
      else
        @notify "Command \"#{name}\" not found"

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
