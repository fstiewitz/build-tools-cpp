Project = require './project'
path = require 'path'
fs = require 'fs'
{Emitter} = require 'atom'

module.exports =
  class Projects
    filename: null
    data: {}

    constructor: (arg) ->
      if arg?
        @filename = arg
      else
        @getFileName()
      @touchFile()
      @getData()
      @emitter = new Emitter

    destroy: ->
      @emitter.dispose()

    getFileName: ->
      @filename = path.join(path.dirname(atom.config.getUserConfigPath()),"build-tools-cpp.projects")

    onFileChange: (callback) ->
      @emitter.on 'file-change', callback

    getData: ->
      CSON = require 'season'
      data = CSON.readFileSync @filename
      Object.keys(data).forEach (key) =>
        @data[key] = new Project(key, data[key], @setData)

    setData: =>
      CSON = require 'season'
      try
        CSON.writeFileSync @filename, @data
        @emitter.emit 'file-change'
      catch error
        atom.notifications?.addError "Settings could not be written to #{@filename}"

    touchFile: ->
      if not fs.existsSync @filename
        fs.writeFileSync @filename, '{}'

    addProject: (path) ->
      if @data[path]?
        atom.notifications?.addError "Project \"#{path}\" already exists"
      else
        @data[path] = new Project(path, {commands: [], dependencies: []}, @setData)
        @setData()

    removeProject: (path) ->
      if @data[path]?
        delete @data[path]
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
