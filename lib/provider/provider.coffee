{Disposable} = require 'atom'
path = require 'path'

module.exports =
  modules:
    bt: require './build-tools'

  addModule: (key, mod) ->
    return if @modules[key]?
    @modules[key] = mod
    new Disposable(=>
      @removeModule key
    )

  removeModule: (key) ->
    delete @modules[key]

  reset: ->
    for k in Object.keys(@modules)
      @removeModule k unless k is 'bt'

  getAvailableModules: (filePath) ->
    available = {}
    p = filePath.split(path.sep)
    i = p.length
    while i isnt 0
      project = p.slice(0, i).join(path.sep)
      for k in Object.keys(@modules)
        if @modules[k].available(project)
          available[project] ?= []
          available[project].push k
      break if project in atom.project.getPaths()
      i = i - 1
    return available

  loadCommands: (filePath) ->
    
