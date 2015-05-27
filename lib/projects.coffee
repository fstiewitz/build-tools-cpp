fs = require 'fs'
path = require 'path'

module.exports =
  class Projects
    filename: ""
    data: {}

    initialize: ->
      @getFileName()
      @touchFile()
      @getData()

    destroy: ->
      @setData()

    getFileName: ->
      @filename = path.dirname(atom.config.getUserConfigPath()) + "/build-tools-cpp.projects"

    getData: ->
      CSON = require 'season'
      CSON.readFile @filename, (error, filedata) =>
        unless error
          @data = filedata
        done?()

    setData: ->
      CSON = require 'season'
      CSON.writeFile @filename, @data, (error) =>
        if error
          atom.notifications?.addError "Settings could not be written to #{@filename}"

    touchFile: ->
      fs.exists @filename, (exists) =>
        unless exists
          fs.writeFile @filename, '{}', (error) ->
            if error
              atom.notifications?.addError "Could not open #{@filename}"

    addProject: (path) ->
      @data[path] = {}
      @data[path]["commands"] = []
      @setData

    addCommand: (path, item) ->
      if @data[path]?
        if not @commandExists path,item
          @data[path]["commands"].push(item)
          @setData

    commandExists: (path, item) ->
      if @data[path]?
        for c in @data[path]["commands"]
          if c.name is item.name
            return true
        return false
      return false

    getCommands: (path) ->
      @data[path]["commands"]

    getProjects: ->
      (p for p in @data)

    getProject: (path) ->
      @data[path]

    setProject: (path, pdata) ->
      @data[path] = pdata
