{Disposable} = require 'atom'

Command = null
Project = null
Input = null

module.exports =
  modules:
    console: require './console'
    linter: require './linter'
    buffer: require './buffer'
    file: require './file'

  addModule: (key, mod) ->
    return if @modules[key]? and not @isCoreName(key)
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
    Command = null
    Project = null
    Input = null

  activate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true if mod.active?
    return true unless mod.activate?
    Command ?= require '../provider/command'
    Project ?= require '../provider/project'
    Input ?= require '../provider/input'
    mod.activate(Command, Project, Input)
    mod.active = true

  deactivate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true unless mod.active?
    return true unless mod.deactivate?
    mod.deactivate()
    mod.active = null
    return true

  isCoreName: (key) ->
    key in ['console', 'linter', 'buffer', 'file']
