cp = require 'child_process'
parser = require './build-parser.coffee'
wc = require './command-wildcards.coffee'

{CompositeDisposable} = require 'atom'

module.exports =

  buildToolsView: null
  settingsView: null
  stepchild: null
  subscriptions: null

  activate: (state) ->
    atom.config.set('build-tools-cpp',state);
    BuildToolsCommandOutput = require './build-tools-view'
    SettingsView = require './settings-view'
    @buildToolsView = new BuildToolsCommandOutput
    @settingsView = new SettingsView
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:pre-configure': => @step1()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:configure': => @step2()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:make': => @step3()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'build-tools-cpp:settings': => @settings()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @cancel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close': => @cancel()

  deactivate: ->
    @stepchild?.kill('SIGKILL')
    @subscriptions.dispose()
    @buildToolsView.destroy()

  serialize: ->
    atom.config.get('build-tools-cpp')

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
      atom.workspaceView.trigger('linter:lint')

  settings: ->
      @buildToolsView.showBox()
      @buildToolsView.showSettings(@settingsView)

  spawn: (cmd_string,cwd_string) ->
    if cmd_string isnt ''
      cmd_list = @split cmd_string
      cmd = @getcommand cmd_list
      parser.clearVars()
      wd = parser.getWD parser.getProjectPath(),cwd_string
      if wd isnt ''
        if (dependency = parser.hasDependencies wd, cmd.cmd, cmd.arg) is ""
          @buildToolsView.show()
          @buildToolsView.setHeader(cmd.cmd)
          @buildToolsView.clear()
          parser.unlint()
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
            @lint()
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
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd_string = wc.replaceWildcards(atom.config.get('build-tools-cpp.Pre_Configure_Command'),cwd_string)
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''
      @stepchild.stderr.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''

  step2: ->
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd_string = wc.replaceWildcards(atom.config.get('build-tools-cpp.Configure_Command'),cwd_string)
    cmd = @spawn cmd_string, cwd_string
    if @stepchild
      @stepchild.stdout.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''
      @stepchild.stderr.on 'data', (data) =>
        @buildToolsView.outputLineParsed data, ''

  step3: ->
    cwd_string = atom.config.get('build-tools-cpp.BuildFolder')
    cmd_string = wc.replaceWildcards(atom.config.get('build-tools-cpp.Build_Command'),cwd_string)
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

  config:
    UseLinterIfAvailable:
      title: 'Inline highlighting'
      description: 'Highlight errors and warnings in your code ( requires Linter plugin )'
      type: 'boolean'
      default: true
    Pre_Configure_Command:
      title: 'Pre configure command'
      description: 'Command to execute'
      type: 'string'
      default: ''
    Configure_Command:
      title: 'Configure command'
      description: 'Command to execute'
      type: 'string'
      default: ''
    Build_Command:
      title: 'Build command'
      description: 'Command to build your project'
      type: 'string'
      default: 'make'
    BuildFolder:
      title: 'Build folder'
      description: 'All commands will be executed from this folder'
      type: 'string'
      default: '.'
    ErrorHighlighting:
      title: 'Error highlighting'
      description: 'Highlight errors in console'
      type: 'boolean'
      default: true
    SourceFileExtensions:
      title: 'File extensions'
      description: 'Types of source files'
      type: 'array'
      default: ['.cpp','.h','.c','.hpp']
      items:
          type: 'string'
