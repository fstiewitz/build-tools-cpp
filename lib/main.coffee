cp = require 'child_process'
parser = require './build-parser.coffee'
wc = require './command-wildcards.coffee'
ml = require './message-list.coffee'

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

  getQuoteIndex: (line) ->
    c1 = line.indexOf('"')
    if c1 isnt -1
      return {index: c1, character: '"'}
    c1 = line.indexOf("'")
    return {index: c1, character: "'"}

  split: (cmd_string) ->
      args = []
      cmd_list = cmd_string.split(' ')
      instring = false
      while (cmd_list.length isnt 0)
        if not instring
          args.push cmd_list[0]
        else
          args[args.length-1] += ' ' + cmd_list[0]
        qi = @getQuoteIndex(cmd_list[0])
        if qi.index isnt -1
          if instring
            instring = false
          else
            if cmd_list[0].substr(qi.index+1).indexOf(qi.character) is -1
              instring = true
        cmd_list.shift()
      return args

  getcommand: (cmd_string, shell) ->
    command = {
      cmd: "",
      arg: [],
      env: {}
    }
    command.env = process.env
    if shell
      sh = atom.config.get('build-tools-cpp.ShellCommand')
      sha = sh.split(' ')
      command.cmd = sha[0]
      command.arg = sha.slice(1)
      command.arg.push(cmd_string)
    else
      args = @split cmd_string
      reg = /[\"\']/
      for a,i in args
        if reg.test(a[0]) and reg.test(a[a.length - 1])
          args[i]=a.slice(1,-1)
      command.cmd = args[0]
      command.arg = args.slice(1)
    command

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
      cmd = @getcommand cmd_string, shell
      parser.clearVars()
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
      @stepchild.on 'exit', (exitcode, signal) =>
        consoleview?.setHeader
        (cmd.cmd + ": finished with exitcode #{exitcode}") if exitcode?
        consoleview?.setHeader
        (cmd.cmd + ": finished with signal #{signal}") if signal?
        consoleview?.finishConsole()
        @lint()
        @stepchild = null
      return cmd
    return

  execute: (id) ->
    if (path=atom.workspace.getActiveTextEditor()?.getPath())?
      if (cmd = @projects.getKeyCommand path,id)?
        cmd_string = wc.replaceWildcards(cmd.command,cmd.wd)
        cmd = @spawn cmd_string, cmd.wd, cmd.shell
        if @stepchild
          @stepchild.stdout.on 'data', (data) =>
            consoleview?.outputLineParsed data, ''
          @stepchild.stderr.on 'data', (data) =>
            consoleview?.outputLineParsed data, ''

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
