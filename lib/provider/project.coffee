CSON = require 'season'
Providers = require './provider'

module.exports =
  class ProjectConfig

    constructor: (@projectPath, @filePath) ->
      @providers = []
      try
        {@providers} = CSON.readFileSync @filePath
        for p, i in @providers
          @providers[i].model = Providers.modules[p.key]?.model
          @providers[i].interface = new @providers[i].model(@projectPath, p.config)

    getCommandByIndex: (id) ->
      f = 0
      for provider in @providers
        return c if (c = provider.interface.getCommandByIndex @projectPath, id - f)?
        f = f + provider.interface.getCommandCount()
