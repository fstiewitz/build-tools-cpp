CSON = require 'season'
Providers = require './provider'

{Emitter} = require 'atom'

module.exports =
  class ProjectConfig

    constructor: (@projectPath, @filePath, @viewed = false) ->
      @emitter = new Emitter if @viewed
      @providers = []
      {providers} = CSON.readFileSync @filePath
      for p in providers
        continue unless Providers.activate(p.key) is true
        l = @providers.push {
          key: p.key
          config: p.config
          model: Providers.modules[p.key].model
          interface: new Providers.modules[p.key].model(@projectPath, p.config, if @viewed then @save)
        }
        continue unless @viewed
        continue unless Providers.modules[p.key].view?
        provider = @providers[l - 1]
        provider.view = new Providers.modules[p.key].view(provider.interface)
      null

    destroy: ->
      @emitter?.dispose()
      for provider in @providers
        provider.view?.destroy?()
        provider.interface.destroy?()

    ############################################################################
    # Event functions
    ############################################################################

    onSave: (callback) ->
      @emitter.on 'save', callback

    ############################################################################
    # Getters
    ############################################################################

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

    getCommandNameObjects: ->
      new Promise((resolve, reject) =>
        @_providers = @providers.slice().reverse()
        @_return = []
        @_getCommandNameObjects resolve, reject
      )

    ############################################################################
    # Setters
    ############################################################################

    addProvider: (key) ->
      return false unless Providers.activate(key) is true
      l = @providers.push
        key: key
        config: {}
        model: Providers.modules[key].model

      @providers[l - 1].interface = new Providers.modules[key].model(@projectPath, @providers[l - 1].config, @save)
      @providers[l - 1].view = new Providers.modules[key].view(@providers[l - 1].interface) if @viewed and Providers.modules[key].view?
      @save()
      return true

    removeProvider: (index) ->
      return false unless @providers.length > index
      @providers.splice(index, 1)[0]
      @save()
      return true

    moveProviderUp: (index) ->
      return false if (index is 0) or (index >= @providers.length)
      @providers.splice(index - 1, 0, @providers.splice(index, 1)[0])
      @save()
      return true

    moveProviderDown: (index) ->
      return false if (index >= @providers.length - 1)
      @providers.splice(index, 0, @providers.splice(index + 1, 1)[0])
      @save()
      return true

    ############################################################################
    # Private functions
    ############################################################################

    _getCommandByIndex: (id, resolve, reject) ->
      return reject("Command ##{id + 1} not found") unless (p = @_providers.pop())?
      return resolve(c) if (c = p.interface?.getCommandByIndex id - @f)?
      @f = @f + (p.interface?.getCommandCount() ? 0)
      @_getCommandByIndex id, resolve, reject

    _getCommandNameObjects: (resolve, reject) ->
      return resolve(@_return) unless (p = @_providers.pop())?
      @_return = @_return.concat ({name: command, singular: Providers.modules[p.key].singular, origin: p.key, id: i} for command, i in p.interface.getCommandNames()) if p.interface?
      @_getCommandNameObjects resolve, reject

    save: =>
      providers = []
      for provider in @providers
        providers.push
          key: provider.key
          config: provider.config
      CSON.writeFileSync @filePath, {providers}
      @emitter.emit 'save'
