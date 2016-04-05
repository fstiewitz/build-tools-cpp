{Disposable} = require 'atom'

Command = null
Project = null
Input = null

module.exports =
  modules:
    child_process: require './child-process'
    ptyw: require './ptyw'

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
    @modules.child_process = require './child-process'
    @modules.ptyw = require './ptyw'
    Command = null
    Project = null
    Input = null

  activate: (key) ->
    return false unless key?
    mod = @modules[key]
    return false unless mod?
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
    key in ['child_process', 'ptyw']
