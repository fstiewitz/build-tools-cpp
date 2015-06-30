command = require './command'
ll = require './linter-list'
Profiles = require './profiles/profiles'

{CompositeDisposable, BufferedProcess} = require 'atom'

settingsviewuri= 'atom://build-tools-settings'
SettingsView= null
settingsview= null

ConsoleView= null
consoleview= null

SelectionView= null
selectionview= null

createConsoleView= ->
  ConsoleView ?= require './console'
  consoleview ?= new ConsoleView()

createSelectionView= ->
  SelectionView ?= require './selection-view.coffee'
  selectionview ?= new SelectionView

createSettingsView= (state) ->
  SettingsView ?= require './settings-view'
  settingsview = new SettingsView(state)
  settingsview

module.exports =

  process: null
  subscriptions: null

  Projects: null
  projects: null

  command_list: null

  createProjectInstance: ->
    @Projects ?= require './projects'
    @projects ?= new @Projects()

  activate: (state) ->
    @createProjectInstance()
    createConsoleView()
    atom.workspace.addOpener (uritoopen) =>
      createSettingsView({uri: uritoopen, @projects, profiles: Profiles}) if uritoopen is settingsviewuri

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:pre-configure': => @execute(2)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:configure': => @execute(1)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:make': => @execute(0)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:show': @show
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:settings': ->
      atom.workspace.open(settingsviewuri)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:commands': => @selection()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': @cancel
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': @cancel
    @subscriptions.add atom.project.onDidChangePaths =>
      settingsview?.reload()

  deactivate: ->
    @process?.kill()
    @process = null
    @subscriptions.dispose()
    consoleview?.destroy()
    consoleview = null
    ConsoleView = null
    selectionview?.destroy()
    selectionview = null
    SelectionView = null
    settingsview?.destroy()
    settingsview = null
    SettingsView = null
    @projects?.destroy()
    @Projects = null
    @projects = null

  show: =>
    consoleview?.showBox()

  kill: ->
    @process?.kill()
    @process = null

  cancel: =>
    if @process?
      @kill()
    consoleview?.cancel()

  selection: ->
    if (path=atom.workspace.getActiveTextEditor()?.getPath())?
      if (projectpath=@projects.getNextProjectPath path) isnt ''
        project = @projects.getProject projectpath
        createSelectionView()
        selectionview.show project, (name) =>
          if (command = project.getCommand name)?
            @command_list = @projects.generateDependencyList command
            @spawn @command_list.splice(0,1)[0]

  saveall: ->
    if (v=atom.workspace.getActiveTextEditor())?
      ev = atom.views.getView(v)
      atom.commands.dispatch(ev, "window:save-all")

  spawn: (res, clear = true) ->
    {cmd,args,env,cwd} = res.parseCommand()
    consoleview?.createOutput res
    consoleview?.showBox()
    consoleview?.setHeader("#{res.name} of #{res.project}")
    consoleview?.clear() if clear
    consoleview?.unlock()
    @process = new BufferedProcess(
      command: cmd
      args: args
      options:
        cwd: cwd,
        env: env
      stdout: (data) =>
        consoleview?.stdout?.in data
      stderr: (data) =>
        consoleview?.stderr?.in data
      exit: (exitcode) =>
        consoleview?.finishConsole() if (@command_list.length is 0) or exitcode isnt 0
        if exitcode is 0
          consoleview?.setHeader ("#{res.name} of #{res.project}: finished with exitcode #{exitcode}")
          @spawn @command_list.splice(0,1)[0], false if (@command_list.length isnt 0)
        else
          consoleview?.setHeader("#{res.name} of #{res.project}: <span class='error'>finished with exitcode #{exitcode}</span>")
      )
    @process.onWillThrowError ({error, handle}) =>
      consoleview?.hideOutput()
      consoleview?.setHeader("#{res.name} of #{res.project}: received #{error}")
      consoleview?.lock()
      @command_list = []
      handle()

  execute: (id) ->
    @saveall() if atom.config.get('build-tools-cpp.SaveAll')
    if (path=atom.workspace.getActiveTextEditor()?.getPath())?
      if (projectpath=@projects.getNextProjectPath path) isnt ''
        project = @projects.getProject projectpath
        bindings = ['make','configure','preconfigure']
        if (b = bindings[id])?
          if (key = project.key[b])?
            project = @projects.getProject key.project
            command = project.getCommand key.command
          else
            command = project.getCommandByIndex id
        else
          command = project.getCommandByIndex id
        if command?
          @command_list = @projects.generateDependencyList command
          ll.messages = {}
          @spawn @command_list.splice(0,1)[0]

  provideLinter: ->
    grammarScopes: ['source.c++', 'source.cpp', 'source.c']
    scope: 'file'
    lintOnFly: false
    lint: (editor) =>
      filePath = editor.getPath()
      messages = []
      if (m=ll.messages[ll.path.basename(filePath)])?
        for item in m
          messages.push(
            type: item[4]
            text: item[5]
            filePath: filePath
            range: [
              [item[2]-1,0]
              [item[2]-1,if item[3]? then item[3]-1 else 9999]
            ]
          )
      messages


  config:
    SaveAll:
      title: 'Save all'
      description: 'Save all files before executing your build command'
      type: 'boolean'
      default: true
    SourceFileExtensions:
      title: 'File extensions'
      description: 'Types of source files'
      type: 'array'
      default: ['.cpp','.h','.c','.hpp']
      items:
        type: 'string'
    ShellCommand:
      title: 'Shell Command'
      description: 'Shell command to execute when "Execute in Shell" is enabled. Command string is appended at the end of this string'
      type: 'string'
      default: 'bash -c'
