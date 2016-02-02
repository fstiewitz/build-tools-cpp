{Disposable} = require 'atom'

module.exports =
  profiles:
    gcc_clang: require './gcc_clang'
    apm_test: require './apm_test'
    java: require './javac'
    python: require './python'
    modelsim: require './modelsim'

  versions:
    gcc_clang: 1
    apm_test: 1
    java: 1
    python: 1
    modelsim: 1

  addProfile: (key, profile, version = 1) ->
    return if @profiles[key]? and not @isCoreName(key)
    @profiles[key] = profile
    @versions[key] = version
    new Disposable(=>
      @removeProfile key
    )

  removeProfile: (key) ->
    delete @profiles[key]
    delete @versions[key]

  reset: ->
    for k in Object.keys(@profiles)
      @removeProfile k
    @profiles.gcc_clang = require './gcc_clang'
    @profiles.apm_test = require './apm_test'
    @profiles.java = require './javac'
    @profiles.python = require './python'
    @profiles.modelsim = require './modelsim'
    @versions.gcc_clang = 1
    @versions.apm_test = 1
    @versions.java = 1
    @versions.python = 1
    @versions.modelsim = 1

  isCoreName: (key) ->
    key in ['gcc_clang', 'apm_test', 'java', 'python', 'modelsim']
