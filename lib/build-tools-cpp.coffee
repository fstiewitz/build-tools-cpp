cp = require 'child_process'
parser = require './build-parser.coffee'
wc = require './command-wildcards.coffee'
ml = require './message-list.coffee'

{CompositeDisposable} = require 'atom'

settingsviewuri= 'atom://build-tools-settings'
SettingsView= null
settingsview= null

BuildToolsView= null
buildtoolsview= null

createBuildToolsView= ->
  BuildToolsView ?= require './build-tools-view'
  buildtoolsview ?= new BuildToolsView
  buildtoolsview

createSettingsView= (state) ->
  SettingsView ?= require './settings-view'
  settingsview ?= new SettingsView(state)
  settingsview

module.exports =

  stepchild: null
  subscriptions: null

  activate: (state) ->
    createBuildToolsView()
    atom.workspace.addOpener (uritoopen) ->
      createSettingsView(uri: uritoopen) if uritoopen is settingsviewuri

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:pre-configure': => @execute("echo TODO")
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:configure': => @execute("echo TODO")
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:make': => @executeMake()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:settings': ->
      atom.workspace.open(settingsviewuri)
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @cancel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': => @cancel()

  deactivate: ->
    @stepchild?.kill('SIGKILL')
    @subscriptions.dispose()
    buildtoolsview?.destroy()

  toggle: ->
    buildtoolsview?.toggleBox()

  kill: ->
    @stepchild?.kill('SIGTERM')
    @stepchild = null

  cancel: ->
    if @stepchild?
      @kill()
    else
      buildtoolsview?.cancel()

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

  getcommand: (cmd_list) ->
    command = {
      cmd: "",
      arg: [],
      env: {}
    }
    command.env = process.env
    cmd_reached = false
    for e in cmd_list
      if e.indexOf('=') isnt -1 and (not cmd_reached)
        epair = e.split('=')
        t = parser.removeQuotes epair[1]
        if t isnt ''
          command.env[epair[0]]=t
      else if cmd_reached
        t = parser.removeQuotes e
        command.arg.push t if t isnt ''
      else
        cmd_reached = true
        command.cmd = parser.removeQuotes e
    return command

  lint: ->
    if (v=atom.workspace.getActiveTextEditor())?
      ev = atom.views.getView(v)
      atom.commands.dispatch(ev, "linter:lint")

  saveall: ->
    if (v=atom.workspace.getActiveTextEditor())?
      ev = atom.views.getView(v)
      atom.commands.dispatch(ev, "window:save-all")

  spawn: (cmd_string,cwd_string) ->
    if cmd_string isnt ''
      cmd_list = @split cmd_string
      cmd = @getcommand cmd_list
      parser.clearVars()
      wd = parser.getWD parser.getProjectPath(),cwd_string
      if wd isnt ''
        if (dependency = parser.hasDependencies wd, cmd.cmd, cmd.arg) is ""
          buildtoolsview?.showBox()
          buildtoolsview?.setHeader(cmd.cmd)
          buildtoolsview?.clear()
          parser.unlint()
          buildtoolsview?.unlock()
          @stepchild = cp.spawn(cmd.cmd, cmd.arg, { cwd: wd, env: cmd.env })
          @stepchild.on 'error', (error) =>
            buildtoolsview?.hideOutput()
            buildtoolsview?.setHeader("#{cmd_string}: received #{error}")
            buildtoolsview?.lock()
            @kill()
          @stepchild.on 'exit', (exitcode, signal) =>
            buildtoolsview?.setHeader
            (cmd.cmd + ": finished with exitcode #{exitcode}") if exitcode?
            buildtoolsview?.setHeader
            (cmd.cmd + ": finished with signal #{signal}") if signal?
            buildtoolsview?.finishConsole()
            @lint()
            @stepchild = null
          return cmd
        else if dependency is undefined
          buildtoolsview?.lock()
          buildtoolsview?.showBox()
          buildtoolsview?.hideOutput()
          buildtoolsview?.setHeader("Error parsing arguments")
        else
          buildtoolsview?.lock()
          buildtoolsview?.showBox()
          buildtoolsview?.hideOutput()
          buildtoolsview?.setHeader("Error: File #{dependency} not found")
      else
        buildtoolsview?.lock()
        buildtoolsview?.showBox()
        buildtoolsview?.hideOutput()
        buildtoolsview?.setHeader("Error: Build folder #{cwd_string} not found")
        return
    return

  execute: (command) ->
    cwd_string = "build"
    cmd_string = wc.replaceWildcards(command,cwd_string)
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        buildtoolsview?.outputLineParsed data, ''
      @stepchild.stderr.on 'data', (data) =>
        buildtoolsview?.outputLineParsed data, ''

  executeMake: ->
    @saveall() if atom.config.get('build-tools-cpp.SaveAll')
    cwd_string = "build"
    cmd_string = wc.replaceWildcards("make -j4",cwd_string)
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      if false
        @stepchild.stdout.on 'data', (data) =>
          buildtoolsview?.outputLineParsed data, 'make'
      else
        @stepchild.stdout.on 'data', (data) =>
          buildtoolsview?.outputLineParsed data, ''
      if true
        @stepchild.stderr.on 'data', (data) =>
          buildtoolsview?.outputLineParsed data, 'make'
      else
        @stepchild.stderr.on 'data', (data) =>
          buildtoolsview?.outputLineParsed data, '' #No highlighting

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
