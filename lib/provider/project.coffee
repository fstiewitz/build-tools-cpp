CSON = require 'season'
Providers = require './provider'

module.exports =
  class ProjectConfig

    constructor: (@projectPath, @filePath) ->
      @providers = []
      {providers} = CSON.readFileSync @filePath
      for p in providers
        continue unless Providers.activate(p.key) is true
        @providers.push {
          key: p.key
          config: p.config
          model: Providers.modules[p.key]?.model
          interface: new Providers.modules[p.key]?.model(@projectPath, p.config)
        }
      null

    getCommandByIndex: (id) ->
      f = 0
      for provider in @providers
        return c if (c = provider.interface?.getCommandByIndex id - f)?
        f = f + provider.interface?.getCommandCount()
