cp = require 'child_process'
parser = require './build-parser'
wc = require './command-wildcards'
ml = require './message-list'
command = require './command'
output = require './output'

{CompositeDisposable} = require 'atom'

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

  stepchild: null
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
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:pre-configure': => @execute(0)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:configure': => @execute(1)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:make': => @execute(2)
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:settings': ->
      atom.workspace.open(settingsviewuri)
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @cancel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': => @cancel()
    @subscriptions.add atom.project.onDidChangePaths =>
      settingsview?.updateProjects()

  deactivate: ->
    @stepchild?.kill('SIGKILL')
    @subscriptions.dispose()
    consoleview?.destroy()
    @projects?.destroy()

  toggle: ->
    consoleview?.toggleBox()

  kill: ->
    @stepchild?.kill('SIGTERM')
    @stepchild = null

  cancel: ->
    if @stepchild?
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

  spawn: (cmd_string,cwd_string,shell) ->
    if cmd_string isnt ''
      cmd = command.getCommand cmd_string, shell
      output.clear()
      consoleview?.showBox()
      consoleview?.setHeader(cmd.cmd)
      consoleview?.clear()
      parser.unlint()
      consoleview?.unlock()
      @stepchild = cp.spawn(cmd.cmd, cmd.arg, { cwd: cwd_string, env: cmd.env })
      @stepchild.on 'error', (error) =>
        consoleview?.hideOutput()
        consoleview?.setHeader("#{cmd_string}: received #{error}")
        consoleview?.lock()
        @kill()
      @stepchild.on 'close', (exitcode) =>
        consoleview?.setHeader (cmd.cmd + ": finished with exitcode #{exitcode}")
        consoleview?.finishConsole()
        @lint()
        @stepchild = null

  execute: (id) ->
    if (path=atom.workspace.getActiveTextEditor()?.getPath())?
      if (cmd = @projects.getKeyCommand path,id)?
        cmd_string = wc.replaceWildcards(cmd.cmd.command,cmd.cmd.wd)
        @spawn cmd_string, cmd.cmd.wd, cmd.cmd.shell
        if @stepchild?
          @stepchild.stdout.on 'data', (data) =>
            consoleview?.outputLineParsed data, {format: cmd.cmd.stdout, wd: @projects.resWD(cmd)}
          @stepchild.stderr.on 'data', (data) =>
            consoleview?.outputLineParsed data, {format: cmd.cmd.stderr, wd: @projects.resWD(cmd)}

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
