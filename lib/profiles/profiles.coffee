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
    delete @profiles[key]

  reset: ->
    for k in Object.keys(@profiles)
      @removeProfile k unless k in ['gcc_clang', 'apm_test', 'java', 'python', 'modelsim']
    @profiles.gcc_clang = require './gcc_clang'
    @profiles.apm_test = require './apm_test'
    @profiles.java = require './javac'
    @profiles.python = require './python'
    @profiles.modelsim = require './modelsim'
