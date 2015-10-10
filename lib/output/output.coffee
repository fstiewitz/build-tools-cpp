{Disposable} = require 'atom'

module.exports =
  modules:
    console: require './console'
    linter: require './linter'
    buffer: require './buffer'
    file: require './file'

  addModule: (key, mod) ->
    return if @modules[key]?
    @modules[key] = mod
    new Disposable(=>
      @deactivate key
      @removeModule key
    )

  removeModule: (key) ->
    delete @modules[key]

  reset: ->
    for k in Object.keys(@modules)
      @deactivate k
      @removeModule k
    @modules.console = require './console'
    @modules.linter = require './linter'
    @modules.buffer = require './buffer'
    @modules.file = require './file'

  activate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true if mod.active?
    return true unless mod.activate?
    mod.activate()
    mod.active = true

  deactivate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true unless mod.active?
    return true unless mod.deactivate?
    mod.deactivate()
    mod.active = null
    return true
