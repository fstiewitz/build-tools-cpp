{Disposable} = require 'atom'
path = require 'path'

module.exports =
  modules:
    shell: require './shell'
    wildcards: require './wildcards'
    save_all: require './save_all'

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
      @removeModule k unless k in ['shell', 'wildcards', 'save_all']

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
