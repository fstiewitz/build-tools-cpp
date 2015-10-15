{Disposable} = require 'atom'
path = require 'path'

Command = null
Project = null
Input = null

module.exports =
  modules:
    bt: require './build-tools'
    bte: require './build-tools-external'

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
    @modules.bt = require './build-tools'
    @modules.bte = require './build-tools-external'
    Command = null
    Project = null
    Input = null

  activate: (key) ->
    mod = @modules[key]
    return unless mod?
    return true if mod.active?
    return true unless mod.activate?
    Command ?= require './command'
    Project ?= require './project'
    Input ?= require './input'
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
    key in ['bt', 'bte']
