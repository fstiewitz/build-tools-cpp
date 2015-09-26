Input = require './provider/input'
Command = require './provider/command'

LinterList = null
[ProfileModules, OutputModules, ModifierModules, ProviderModules] = []

{CompositeDisposable} = require 'atom'

CommandEditPane = null

module.exports =

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'build-tools:third-command': -> Input.key(2)
      'build-tools:second-command': -> Input.key(1)
      'build-tools:first-command': -> Input.key(0)
      'build-tools:commands': -> Input.selection()
    @subscriptions.add atom.views.addViewProvider Command, (command) ->
      command.oldname = command.name
      CommandEditPane ?= require './view/command-edit-pane'
      new CommandEditPane(command)

  deactivate: ->
    @subscriptions.dispose()
    (ModifierModules ? require './modifier/modifier').reset()
    (ProviderModules ? require './provider/provider').reset()
    (OutputModules ? require './output/output').reset()
    ModifierModules = null
    ProviderModules = null
    OutputModules = null
    CommandEditPane = null

  provideLinter: ->
    grammarScopes: ['*']
    scope: 'project'
    lintOnFly: false
    lint: ->
      LinterList ?= require './linter-list'
      LinterList.messages

  provideInput: ->
    Input.input

  consumeModifierModule: ({key, mod}) ->
    ModifierModules ?= require './modifier/modifier'
    ModifierModules.addModule key, mod

  consumeProfileModule: ({key, profile}) ->
    ProfileModules ?= require './profiles/profiles'
    ProfileModules.addProfile key, profile

  consumeProviderModule: ({key, mod}) ->
    ProviderModules ?= require './provider/provider'
    ProviderModules.addModule key, mod

  consumeOutputModule: ({key, mod}) ->
    OutputModules ?= require './output/output'
    OutputModules.addModule key, mod

  config:
    CloseOnSuccess:
      title: 'Close console on success'
      description: 'Value is used in command settings. 0 to hide console on success, >0 to hide console after x seconds'
      type: 'integer'
      default: 3
