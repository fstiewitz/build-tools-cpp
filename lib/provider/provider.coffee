{Disposable} = require 'atom'
path = require 'path'
Command = require './command'

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
      @deactivate k
      @removeModule k
    @modules.bt = require './build-tools'

  activate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true if mod.active?
    return true unless mod.activate?
    mod.activate(Command)
    mod.active = true

  deactivate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true unless mod.active?
    return true unless mod.deactivate?
    mod.deactivate()
    mod.active = null
    return true
