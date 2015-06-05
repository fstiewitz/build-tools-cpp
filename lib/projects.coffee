Project = require './project'
path = require 'path'
fs = require 'fs'
{Emitter} = require 'atom'

module.exports =
  class Projects
    filename: null
    data: {}
    writing: false

    constructor: (arg) ->
      if arg?
        @filename = arg
      else
        @getFileName()
      @touchFile()
      @getData()
      @emitter = new Emitter
      @watcher = fs.watch @filename, @reload

    destroy: ->
      @watcher.close()
      @emitter.dispose()

    reload: (event,filename) =>
      if not @writing
        @getData()
        @emitter.emit 'file-change'
      else
        @writing = false

    getFileName: ->
      @filename = path.join(path.dirname(atom.config.getUserConfigPath()),"build-tools-cpp.projects")

    onFileChange: (callback) ->
      @emitter.on 'file-change', callback

    getData: ->
      CSON = require 'season'
      data = CSON.readFileSync @filename
      Object.keys(data).forEach (key) =>
        @data[key] = new Project(key, data[key], @setData, @checkDependencies)

    setData: =>
      CSON = require 'season'
      try
        @writing = true
        CSON.writeFileSync @filename, @data
        @emitter.emit 'file-change'
      catch error
        atom.notifications?.addError "Settings could not be written to #{@filename}"

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
        else
          #Removed command
          for target in removed.targetOf
            project = @data[target.project]
            project.dependencies = project.dependencies.filter (value) =>
              not ((value.from.project is target.project) and (value.from.command is target.command))
          project = @data[removed.project]
          project.dependencies = project.dependencies.filter (value) =>
            not (value.from.command is removed.name)
      if added?
        #Add dependency
        @data[added.to.project].getCommand(added.to.command).targetOf.push(added.from)
      if replaced?
        #Replaced command
        replaced.new['targetOf'] = replaced.old.targetOf
        for target in replaced.old.targetOf
          project = @data[target.project]
          project.dependencies.forEach (value,index) ->
            if (value.from.project is target.project) and (value.from.command is target.command)
              project.dependencies[index].to.command = replaced.new.name
        project = @data[replaced.old.project]
        project.dependencies.forEach (value,index) ->
          if (value.from.command is replaced.old.name)
            project.dependencies[index].from.command = replaced.new.name



    touchFile: ->
      if not fs.existsSync @filename
        fs.writeFileSync @filename, '{}'

    addProject: (path) ->
      if @data[path]?
        atom.notifications?.addError "Project \"#{path}\" already exists"
      else
        @data[path] = new Project(path, {commands: [], dependencies: []}, @setData, @checkDependencies)
        @setData()

    removeProject: (path) ->
      if @data[path]?
        delete @data[path]
        @setData()
      else
        atom.notifications?.addError "Project \"#{path}\" not found"

    getNextProjectPath: (file) ->
      p = file.split(path.sep)
      i = p.length
      while (i isnt 0) and (@data[p.slice(0,i).join(path.sep)] is undefined)
        i=i-1
      p.slice(0,i).join(path.sep)

    getProject: (path) ->
      @data[path]

    getProjects: ->
      p = []
      Object.keys(@data).forEach (key) ->
        p.push(key)
      p
