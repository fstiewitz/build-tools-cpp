cp = require 'child_process'
parser = require './build-parser.coffee'
wc = require './command-wildcards.coffee'

module.exports =

  buildToolsView: null
  stepchild: null

  activate: (state) ->
    @projdir = atom.project.getPath()
    BuildToolsCommandOutput = require './build-tools-view'
    @buildToolsView = new BuildToolsCommandOutput()
    atom.workspaceView.command "build-tools-cpp:pre-configure", ".editor", =>
      @step1()
    atom.workspaceView.command "build-tools-cpp:configure", ".editor", =>
      @step2()
    atom.workspaceView.command "build-tools-cpp:make", ".editor", =>
      @step3()
    atom.workspaceView.command "build-tools-cpp:toggle", ".editor", => @toggle()
    atom.workspaceView.on "core:cancel core:close", => @cancel()

  deactivate: ->
    @stepchild?.kill('SIGKILL')
    @buildToolsView.destroy()

  toggle: ->
    @buildToolsView.toggleBox()

  kill: ->
    @stepchild?.kill('SIGTERM')
    @stepchild = null

  cancel: ->
    if @stepchild?
      @kill()
    else
      @buildToolsView.hide()

  getQuoteIndex: (line) ->
    c1 = line.indexOf("\"")
    if c1 isnt -1
      return {index: c1, character: '\"'}
    c1 = line.indexOf("\'")
    return {index: c1, character: '\''}

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

  spawn: (cmd_string,cwd_string) ->
    if cmd_string isnt ''
      cmd_list = @split cmd_string
      cmd = @getcommand cmd_list
      parser.clearVars()
      wd = parser.getWD @projdir,cwd_string
      if wd isnt ''
        if (dependency = parser.hasDependencies wd, cmd.cmd, cmd.arg) is ""
          @buildToolsView.show()
          @buildToolsView.setHeader(cmd.cmd)
          @buildToolsView.clear()
          @buildToolsView.unlock()
          @stepchild = cp.spawn(cmd.cmd, cmd.arg, { cwd: wd, env: cmd.env })
          @stepchild.on 'error', (error) =>
            @buildToolsView.setHeaderOnly("#{cmd_string}: received #{error}")
            @buildToolsView.lock()
            @kill()
          @stepchild.on 'exit', (exitcode, signal) =>
            @buildToolsView.setHeader
            (cmd.cmd + ": finished with exitcode #{exitcode}") if exitcode?
            @buildToolsView.setHeader
            (cmd.cmd + ": finished with signal #{signal}") if signal?
            @buildToolsView.finishConsole()
            @stepchild = null
          return cmd
        else if dependency is undefined
          @buildToolsView.lock()
          @buildToolsView.show()
          @buildToolsView.setHeaderOnly("Error parsing arguments")
        else
          @buildToolsView.lock()
          @buildToolsView.show()
          @buildToolsView.setHeaderOnly("Error: File #{dependency} not found")
      else
        @buildToolsView.lock()
        @buildToolsView.show()
        @buildToolsView.setHeaderOnly("Error: Build folder #{cwd_string} not found")
        return
    return

  step1: ->
    cmd_string = wc.replaceWildcards(atom.config.get('build-tools-cpp.Pre_Configure_Command'))
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''
      @stepchild.stderr.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''

  step2: ->
    cmd_string = atom.config.get('build-tools-cpp.Configure_Command')
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''
      @stepchild.stderr.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''

  step3: ->
    cmd_string = atom.config.get('build-tools-cpp.Build_Command')
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''
      if atom.config.get('build-tools-cpp.ErrorHighlighting')
        @stepchild.stderr.on 'data', (data) =>
          @buildToolsView.outputLineParsed data, 'make'
      else
        @stepchild.stderr.on 'data', (data) =>
          @buildToolsView.outputLineParsed data, '' #No highlighting

  configDefaults:
    Pre_Configure_Command: ""
    Configure_Command: ""
    Build_Command: "make"
    BuildFolder: "."
    ErrorHighlighting: true
    SourceFileExtensions: '".cpp",".h",".c",".hpp"'
