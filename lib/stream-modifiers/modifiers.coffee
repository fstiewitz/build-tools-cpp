{Disposable} = require 'atom'

Command = null
Project = null
Input = null

module.exports =
  modules:
    all: require './all'
    regex: require './regex'
    profile: require './profile'
    remansi: require './remansi'

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
    @modules.all = require './all'
    @modules.regex = require './regex'
    @modules.profile = require './profile'
    @modules.remansi = require './remansi'
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
    key in ['all', 'regex', 'profile', 'remansi']
