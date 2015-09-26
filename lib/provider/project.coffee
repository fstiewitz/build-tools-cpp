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

    getCommandById: (origin, id) ->
      for provider in @providers
        if provider.key is origin
          return provider.interface?.getCommandByIndex id

    getCommandByIndex: (id) ->
      new Promise((resolve, reject) =>
        @_providers = @providers.slice().reverse()
        @f = 0
        @_getCommandByIndex id, resolve, reject
      )

    _getCommandByIndex: (id, resolve, reject) ->
      return reject("Command ##{id + 1} not found") unless (p = @_providers.pop())?
      return resolve(c) if (c = p.interface?.getCommandByIndex id - @f)?
      @f = @f + (p.interface?.getCommandCount() ? 0)
      @_getCommandByIndex id, resolve, reject

    getCommandNameObjects: ->
      new Promise((resolve, reject) =>
        @_providers = @providers.slice().reverse()
        @_return = []
        @_getCommandNameObjects resolve, reject
      )

    _getCommandNameObjects: (resolve, reject) ->
      return resolve(@_return) unless (p = @_providers.pop())?
      @_return = @_return.concat ({name: command, singular: Providers.modules[p.key].singular, origin: p.key, id: i} for command, i in p.interface.getCommandNames()) if p.interface?
      @_getCommandNameObjects resolve, reject
