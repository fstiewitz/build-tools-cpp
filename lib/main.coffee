Command = require './command'
ll = require './linter-list'
Profiles = require './profiles/profiles'
OutputModules = require './output/output'
QueueWorker = require './pipeline/queue-worker'

{CompositeDisposable, BufferedProcess} = require 'atom'

settingsviewuri = 'atom://build-tools-settings'
SettingsView = null
settingsview = null

CommandEditPane = null

LocalSettingsView = null
localsettingsview = null

SelectionView = null
selectionview = null

AskView = null
askview = null

Projects = null

createAskView = ->
  AskView ?= require './ask-view'
  askview ?= new AskView

createSelectionView = ->
  SelectionView ?= require './selection-view.coffee'
  selectionview ?= new SelectionView

createSettingsView = (state) ->
  SettingsView ?= require './settings-view'
  settingsview = new SettingsView(state)
  settingsview

createLocalSettingsView = (state) ->
  LocalSettingsView ?= require './local-settings-view'
  localsettingsview = new LocalSettingsView(state)
  localsettingsview

module.exports =

  process: null
  subscriptions: null

  Projects: null
  projects: null

  createProjectInstance: ->
    Projects ?= require './projects'
    @projects ?= new Projects()

  activate: (state) ->
    @createProjectInstance()
    if atom.config.get('build-tools.CloseOnSuccess') is -1
      atom.config.set('build-tools.CloseOnSuccess', 3)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'build-tools:third-command': => @execute(2)
      'build-tools:second-command': => @execute(1)
      'build-tools:first-command': => @execute(0)
      'build-tools:third-command-ask': => @execute(2, true)
      'build-tools:second-command-ask': => @execute(1, true)
      'build-tools:first-command-ask': => @execute(0, true)
      'build-tools:settings': ->
        atom.workspace.open(settingsviewuri)
      'build-tools:commands': => @selection()
      'core:cancel': => @currentWorker?.stop()
      'core:close': => @currentWorker?.stop()
    @subscriptions.add atom.project.onDidChangePaths ->
      settingsview?.reload()
    @subscriptions.add atom.workspace.addOpener (uritoopen) =>
      if uritoopen is settingsviewuri
        createSettingsView({uri: uritoopen, @projects})
      else if uritoopen.endsWith('.build-tools.cson') and (project = Projects.loadLocalFile uritoopen)?
        createLocalSettingsView({uri: uritoopen, @projects, project})
    @subscriptions.add atom.views.addViewProvider Command, (command) ->
      command.oldname = command.name
      CommandEditPane ?= require './view/command-edit-pane'
      new CommandEditPane(command)

  deactivate: ->
    @subscriptions.dispose()
    askview?.destroy()
    askview = null
    AskView = null
    selectionview?.destroy()
    selectionview = null
    SelectionView = null
    settingsview?.destroy()
    settingsview = null
    SettingsView = null
    localsettingsview?.destroy()
    localsettingsview = null
    LocalSettingsView = null
    CommandEditPane = null
    @projects?.destroy()
    @Projects = null
    @projects = null

  saveall: ->
    for editor in atom.workspace.getTextEditors()
      editor.save() if editor.isModified() and editor.getPath()?

  selection: ->
    if (path = atom.workspace.getActiveTextEditor()?.getPath())?
      if (projectpath = @projects.getNextProjectPath path) isnt ''
        project = null
        if Projects.hasLocal projectpath
          project = Projects.loadLocal projectpath
        project ?= @projects.getProject projectpath
        createSelectionView()
        selectionview.show project, (name) =>
          if (command = project.getCommand name)?
            command_list = @projects.generateDependencyList command
            @saveall() if command_list[0].save_all
            @executeQueue command_list

  executeQueue: (queue) ->
    @currentWorker.stop() if @currentWorker? and not @currentWorker.hasFinished()
    @currentWorker = new QueueWorker(queue: queue)
    @currentWorker.run()

  execute: (id, ask = false) ->
    if (path = atom.workspace.getActiveTextEditor()?.getPath())?
      if (projectpath = @projects.getNextProjectPath path) isnt ''
        project = null
        if Projects.hasLocal projectpath
          project = Projects.loadLocal projectpath
        project ?= @projects.getProject projectpath
        if project?
          bindings = ['make', 'configure', 'preconfigure']
          if (b = bindings[id])?
            if (key = project.key[b])?
              project = @projects.getProject key.project
              command = project.getCommand key.command
            else
              command = project.getCommandByIndex id
          else
            command = project.getCommandByIndex id
          if command?
            if ask
              createAskView()
              askview.show command.command, (c) =>
                _command = new Command(command, c)
                @saveall() if command.save_all
                command_list = @projects.generateDependencyList _command
                @executeQueue command_list
            else
              command_list = @projects.generateDependencyList command
              @saveall() if command_list[0].save_all
              @executeQueue command_list

  provideLinter: ->
    grammarScopes: ['*']
    scope: 'project'
    lintOnFly: false
    lint: ->
      ll.messages

  consumeProfile: ({key, profile}) ->
    Profiles.addProfile key, profile

  consumeOutputModule: ({key, mod}) ->
    OutputModules.addModule key, mod

  config:
    SaveAll:
      title: 'Save all'
      description: 'Default value used in command settings. Save all files before executing your build command'
      type: 'boolean'
      default: true
    ShellCommand:
      title: 'Shell Command'
      description: 'Shell command to execute when "Execute in Shell" is enabled'
      type: 'string'
      default: 'bash -c'
    CloseOnSuccess:
      title: 'Close console on success'
      description: 'Value is used in command settings. 0 to hide console on success, >0 to hide console after x seconds'
      type: 'integer'
      default: 3
