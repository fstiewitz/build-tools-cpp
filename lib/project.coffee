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
      item['project'] = @path
      errors = @check(added: item)
      @dependencies.push(new Dependency(item,errors))
      atom.notifications?.addError "Project \"#{errors.project}\" not found" if errors.project?
      atom.notifications?.addError "Command \"#{errors.command}\" not found" if errors.command?
      @save()

    removeCommand: (name) ->
      if (i = @getCommandIndex name) isnt -1
        @check(removed: @commands.splice(i,1)[0])
        @save()
      else
        atom.notifications?.addError "Command \"#{name}\" not found"

    removeDependency: (id) ->
      {targetOf, project, command} = @check(removed: @dependencies.splice(id,1)[0])
      atom.notifications?.addError "Command \"#{command}\" does not depend on removed dependency" if targetOf?
      atom.notifications?.addError "Project \"#{project}\" not found" if project?
      atom.notifications?.addError "Command \"#{command}\" not found" if command?
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
        @check(removed: @commands.splice(i,1)[0])
        @commands.splice(i,0,new Command(item))
        @check(added: item)
        @save()
      else
        atom.notifications?.addError "Command \"#{oldname}\" not found"

    replaceDependency: (oldid, item) ->
      item['project'] = @path
      {targetOf, project, command} = @check(removed: @dependencies.splice(oldid,1))
      atom.notifications?.addError "Command \"#{command}\" does not depend on removed dependency" if targetOf?
      atom.notifications?.addError "Project \"#{project}\" not found" if project?
      atom.notifications?.addError "Command \"#{command}\" not found" if command?
      errors = @check(added: item)
      @dependencies.splice(oldid, 0, new Dependency(item,errors))
      atom.notifications?.addError "Project \"#{errors.project}\" not found" if errors.project?
      atom.notifications?.addError "Command \"#{errors.command}\" not found" if errors.command?
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
