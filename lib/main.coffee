command = require './command'

{CompositeDisposable, BufferedProcess} = require 'atom'

settingsviewuri= 'atom://build-tools-settings'
SettingsView= null
settingsview= null

ConsoleView= null
consoleview= null

createConsoleView= ->
  ConsoleView ?= require './console'
  consoleview ?= new ConsoleView
  consoleview

createSettingsView= (state) ->
  SettingsView ?= require './settings-view'
  settingsview ?= new SettingsView(state)
  settingsview

module.exports =

  process: null
  subscriptions: null

  Projects: null
  projects: null

  createProjectInstance: ->
    @Projects ?= require './projects'
    @projects ?= new @Projects()

  activate: (state) ->
    @createProjectInstance()
    createConsoleView()
    atom.workspace.addOpener (uritoopen) ->
      createSettingsView(uri: uritoopen) if uritoopen is settingsviewuri

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:pre-configure': => @execute(2)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:configure': => @execute(1)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:make': => @execute(0)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:show': => @show()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:settings': ->
      atom.workspace.open(settingsviewuri)
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @cancel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': => @cancel()
    @subscriptions.add atom.project.onDidChangePaths =>
      settingsview?.reload()

  deactivate: ->
    @process?.kill()
    @subscriptions.dispose()
    consoleview?.destroy()
    @projects?.destroy()

  show: ->
    consoleview?.showBox()

  kill: ->
    @process?.kill()
    @process = null

  cancel: ->
    if @process?
      @kill()
    else
      consoleview?.cancel()

  lint: ->
    if (v=atom.workspace.getActiveTextEditor())?
      ev = atom.views.getView(v)
      atom.commands.dispatch(ev, "linter:lint")

  saveall: ->
    if (v=atom.workspace.getActiveTextEditor())?
      ev = atom.views.getView(v)
      atom.commands.dispatch(ev, "window:save-all")

  spawn: (res) ->
    cmd_string = res.cmd.command
    cwd_string = command.getWD res
    shell = res.cmd.shell
    if cmd_string isnt ''
      {cmd,args,env} = command.getCommand cmd_string, shell
      consoleview?.createOutput res
      consoleview?.showBox()
      consoleview?.setHeader(cmd_string)
      consoleview?.clear()
      consoleview?.unlock()
      @process = new BufferedProcess({
        command: cmd,
        args,
        options: {
          cwd: cwd_string,
          env: env
        },
        stdout: (data) =>
          consoleview?.stdout?.in data
        ,
        stderr: (data) =>
          consoleview?.stderr?.in data
        ,
        exit: (exitcode) =>
          consoleview?.setHeader ("#{cmd_string}: finished with exitcode #{exitcode}")
          consoleview?.finishConsole()
          consoleview?.destroyOutput()
        })
      @process.onWillThrowError ({error, handle}) =>
        consoleview?.hideOutput()
        consoleview?.setHeader("#{cmd_string}: received #{error}")
        consoleview?.lock()
        handle()

  execute: (id) ->
    if (path=atom.workspace.getActiveTextEditor()?.getPath())?
      if (cmd = @projects.getKeyCommand path,id)?
        @spawn cmd

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
