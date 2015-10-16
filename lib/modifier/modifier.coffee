{Disposable} = require 'atom'
path = require 'path'

Command = null
Project = null
Input = null

module.exports =
  modules:
    shell: require './shell'
    wildcards: require './wildcards'
    save_all: require './save_all'
    env: require './env'
    dependency: require './dependency'

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
    @modules.shell = require './shell'
    @modules.wildcards = require './wildcards'
    @modules.save_all = require './save_all'
    @modules.env = require './env'
    @modules.dependency = require './dependency'
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
    key in ['shell', 'wildcards', 'save_all', 'env', 'dependency']
