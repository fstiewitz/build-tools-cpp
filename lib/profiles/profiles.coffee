{Disposable} = require 'atom'

module.exports =
  profiles:
    gcc_clang: require './gcc_clang'
    apm_test: require './apm_test'
    java: require './javac'
    python: require './python'
    modelsim: require './modelsim'

  addProfile: (key, profile) ->
    return if @profiles[key]?
    @profiles[key] = profile
    new Disposable(=>
      @removeProfile key
    )

  removeProfile: (key) ->
    @profiles[key] = null
