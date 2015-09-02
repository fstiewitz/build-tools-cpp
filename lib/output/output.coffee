{Disposable} = require 'atom'

module.exports =
  modules:
    console: require './console'
    linter: require './linter'

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
      @removeModule k unless k in ['console', 'linter']
