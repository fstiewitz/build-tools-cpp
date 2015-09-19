path = require 'path'

Provider = require './provider'

getPaths = (folderPath) ->
  p = folderPath.split(path.sep)
  i = p.length
  ret = []
  project = null
  project ?= proj for proj in atom.project.getPaths() when folderPath.startsWith(p)
  while i isnt 0
    _p = p.slice(0, i).join(path.sep)
    ret.push _p
    break if _p is project
    i = i - 1
  return ret

module.exports =
  class CommandCollector

    constructor: (filePath, keys) ->
      folderPath = path.dirname(filePath)
      @modules = {}
      paths = getPaths(folderPath)
      for key in keys
        Provider.activate key
        mod = Provider.modules[key]
        for p in paths
          if (f = mod.availableSync p)?
            @modules[key] ?= []
            @modules[key].push f

    getCommands: ->
      ret = []
      for key in Object.keys(@modules)
        mod = Provider.modules[key]
        for p in @modules[key]
          model = new mod.model(p, true)
          ret = ret.concat(model.getCommands())
          model.destroy?()
          model = null
      return ret
