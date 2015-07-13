Project = require './project'
path = require 'path'
fs = require 'fs'
{Emitter} = require 'atom'
CSON = require 'season'

module.exports =
  class Projects
    filename: null
    data: {}
    writing: false

    constructor: (arg) ->
      if arg?
        @filename = if arg is '' then null else arg
      else
        @getFileName()
      if @filename?
        @touchFile()
        @getData()
        @watcher = fs.watch @filename, @reload
      else
        @data = {}
      @emitter = new Emitter

    destroy: ->
      Object.keys(@data).forEach (key) =>
        project = @data[key]
        if (project.commands.length is 0) and (project.dependencies.length is 0)
          if not (project.key.make? or project.key.configure? or project.key.preconfigure?)
            delete @data[key]
      @watcher?.close()
      @emitter.dispose()
      @setData(false)
      @data = {}

    reload: (event,filename) =>
      if not @writing
        @getData() if @filename?
        @emitter.emit 'file-change'
      else
        @writing = false

    getFileName: ->
      @filename = path.join(path.dirname(atom.config.getUserConfigPath()),"build-tools-cpp.projects")

    onFileChange: (callback) ->
      @emitter.on 'file-change', callback

    getData: ->
      try
        data = CSON.readFileSync @filename
        Object.keys(data).forEach (key) =>
          @data[key] = new Project(key, data[key], @setData, @checkDependencies)
      catch error
        @notify 'Error while reading settings from file'

    setData: (emit = true)=>
      if @filename?
        try
          @writing = true
          CSON.writeFileSync @filename, @data
          @emitter.emit 'file-change' if emit
        catch error
          @notify "Settings could not be written to #{@filename}"
      else
        @reload()

    notify: (message) ->
      atom.notifications?.addError message
      console.log('build-tools: ' + message)

    checkDependencies: ({added, removed, replaced}) =>
      if removed?
        if removed['from']?
          #Removed dependency
          project = @data[removed.to.project]
          command = project.getCommand removed.to.command
          for target,i in command.targetOf
            if (removed.from.project is target.project) and (removed.from.command is target.command)
              command.targetOf.splice(i,1)
              break
        else if removed['targetOf']?
          #Removed command
          for target in removed.targetOf
            if target.command?
              project = @data[target.project]
              project.dependencies = project.dependencies.filter (value) =>
                not ((value.from.project is target.project) and (value.from.command is target.command))
            else
              project = @data[target.project]
              for key in ['make','configure','preconfigure']
                project.key[key] = null if (project.key[key]?.project is removed.project) and (project.key[key]?.command is removed.name)
          project = @data[removed.project]
          omit = []
          project.dependencies = project.dependencies.filter (value) =>
            omit.push(value) if (res = (value.from.command is removed.name))
            not res
          for dep in omit
            @checkDependencies(removed: dep)
        else
          #Removed key binding
          command = @data[removed.key.project].getCommand(removed.key.command).targetOf
          for c,i in command
            if (c.project is removed.project) and (c.command is null)
              command.splice(i,1)
              break
      if added?
        if added['key']?
          #Add key binding
          @data[added.command.project].getCommand(added.command.command).targetOf.push(
            project: added.key,
            command: null
          )
        else
          #Add dependency
          @data[added.to.project].getCommand(added.to.command).targetOf.push(added.from)
      if replaced?
        #Replaced command
        replaced.new['targetOf'] = []
        for target in replaced.old.targetOf
          replaced.new.targetOf.push(target)
          if target.command?
            project = @data[target.project]
            project.dependencies.forEach (value,index) ->
              project.dependencies[index].to.command = replaced.new.name if (value.from.project is target.project) and (value.from.command is target.command)
          else
            project = @data[target.project]
            for key in ['make','configure','preconfigure']
              project.key[key].command = replaced.new.name if (project.key[key]?.project is replaced.old.project) and (project.key[key]?.command is replaced.old.name)

        project = @data[replaced.old.project]
        project.dependencies.forEach (value,index) =>
          if value.from.command is replaced.old.name
            project.dependencies[index].from.command = replaced.new.name
            command = @data[value.to.project].getCommand(value.to.command)
            command.targetOf.forEach (value,index) ->
              command.targetOf[index].command = replaced.new.name if value.command is replaced.old.name

    generateDependencyList: (command, omit = []) ->
      commands = []
      contains= ->
        for obj in omit
          if (obj.project is command.project) and (obj.name is command.name)
            return true
        return false

      if not contains()
        omit.push {
          project: command.project
          name: command.name
        }
        dependencies = @data[command.project].dependencies.filter (value, index) =>
          (value.from.command is command.name)
        for dependency in dependencies
          commands = commands.concat(@generateDependencyList @data[dependency.to.project].getCommand(dependency.to.command), omit)
        commands.push(command)
      commands

    touchFile: ->
      if not fs.existsSync @filename
        fs.writeFileSync @filename, '{}'

    addProject: (path) ->
      if @data[path]?
        @notify "Project \"#{path}\" already exists"
      else
        @data[path] = new Project(path, {commands: [], dependencies: []}, @setData, @checkDependencies)
        @setData()

    getNextProjectPath: (file) ->
      p = file.split(path.sep)
      i = p.length
      while (i isnt 0) and (@data[p.slice(0,i).join(path.sep)] is undefined)
        i=i-1
      p.slice(0,i).join(path.sep)

    getProject: (path) ->
      @data[path]

    getProjects: ->
      Object.keys(@data)
