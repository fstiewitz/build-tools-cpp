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

  activate: (key) ->
    mod = @modules[key]
    return unless mod?
    return unless mod.active?
    return unless mod.activate?
    mod.activate()
    mod.active = true
