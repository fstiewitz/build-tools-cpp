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
        @writing = false
      catch error
        atom.notifications?.addError "Settings could not be written to #{@filename}"

    checkDependencies: ({added,removed}) =>
      if added?
        if added['from']?
          #Added dependency
          project = @data[added.to.project]
          if project?
            command = project.commands[added.to.command]
            if command?
              command.targetOf.push({project: added.project, command: added.from})
              return {}
            else
              return {command: added.to.command}
          else
            return {project: added.to.project}
        else
          #Added command - nothing has to be done
          return ''
      else
        if removed['from']?
          #Removed dependency
          project = @data[removed.to.project]
          if project?
            command = project.commands[removed.to.command]
            if command?
              i = command.targetOf.indexOf({project: removed.project, command: removed.from})
              if i isnt -1
                command.targetOf.splice(i,1)
                return {}
              else
                return {targetOf: {project: removed.project, command: removed.from}}
            else
              return {command: removed.to.command}
          else
            return {project: removed.to.project}
        else
          #Removed command
          for target in removed.targetOf
            project = @data[target.project]
            project.removeDependencies(target) if project?

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
