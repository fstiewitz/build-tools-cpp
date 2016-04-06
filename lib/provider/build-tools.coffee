fs = null
path = null
Emitter = null
Command = null
CommandInfoPane = null
CSON = null
CompositeDisposable = null
{View} = require 'atom-space-pen-views'

notify = (message) ->
  atom.notifications?.addError message
  console.log('build-tools: ' + message)

module.exports =

  name: 'Custom Commands'
  singular: 'Custom Command'

  activate: (command) ->
    fs = require 'fs'
    path = require 'path'
    {Emitter, CompositeDisposable} = require 'atom'
    Command = command
    CommandInfoPane = require '../view/command-info-pane'
    CSON = require 'season'

  deactivate: ->
    fs = null
    path = null
    Emitter = null
    Command = null
    CommandInfoPane = null
    CSON = null

  model:
    class BuildToolsProject

      constructor: ([project, @sourceFile], @config, @_save) ->
        @path = project
        @emitter = new Emitter if @_save?
        @commands = []
        if @config.commands?
          for command in @config.commands
            command.project = @path
            command.source = @sourceFile
            @commands.push(new Command(command))
        @config.commands = @commands

      save: ->
        @_save()

      destroy: ->
        @emitter.dispose() if @_save?
        @_save = null
        @commands = []
        @config = null
        @sourceFile = null
        @path = null

      getCommandByIndex: (id) ->
        @commands[id]

      getCommandCount: ->
        @commands.length

      getCommandNames: ->
        (c.name for c in @commands)

      getCommands: ->
        @commands

      addCommand: (item) ->
        if @getCommandIndex(item.name) is -1
          item['project'] = @path
          item['source'] = @sourceFile
          @commands.push(new Command(item))
          @emitter.emit 'change'
          return true
        else
          notify "Command \"#{item.name}\" already exists"
          return false

      removeCommand: (name) ->
        if (i = @getCommandIndex name) isnt -1
          @commands.splice(i, 1)[0]
          @emitter.emit 'change'
          return true
        else
          notify "Command \"#{name}\" not found"
          return false

      replaceCommand: (oldname, item) ->
        if (i = @getCommandIndex oldname) isnt -1
          item['project'] = @path
          item['source'] = @sourceFile
          @commands.splice(i, 1, item)
          @emitter.emit 'change'
          return true
        else
          notify "Command \"#{oldname}\" not found"
          return false

      moveCommand: (name, offset) ->
        if (i = @getCommandIndex name) isnt -1
          @commands.splice(i + offset, 0, @commands.splice(i, 1)[0])
          @emitter.emit 'change'
          return true
        else
          notify "Command \"#{name}\" not found"
          return false

      hasCommand: (name) ->
        return (@getCommandIndex name isnt -1)

      getCommandIndex: (name) ->
        for cmd, index in @commands
          if cmd.name is name
            return index
        return -1

      onChange: (callback) ->
        @emitter.on 'change', callback

  view:
    class BuildToolsPane extends View

      @content: ->
        @div class: 'inset-panel', =>
          @div class: 'top panel-heading', =>
            @div =>
              @span id: 'provider-name', class: 'inline-block panel-text icon icon-code'
              @span id: 'add-command-button', class: 'inline-block btn btn-xs icon icon-plus', 'Add command'
            @div class: 'config-buttons align', =>
              @div class: 'icon-triangle-up'
              @div class: 'icon-triangle-down'
              @div class: 'icon-x'
          @div class: 'panel-body padded', =>
            @div class: 'command-list', outlet: 'command_list'

      initialize: (@project) ->
        @disposable = @project.onChange =>
          @project.save()
          @command_list.html('')
          @addCommands()

      setCallbacks: (@hidePanes, @showPane) ->

      destroy: ->
        @disposable.dispose()
        @project = null
        @hidePanes = null
        @showPane = null
        @commandPane?.destroy()
        @commandPane = null

      accept: (c) =>
        @project.addCommand c

      attached: ->
        @on 'click', '#add-command-button', (e) =>
          @commandPane?.destroy()
          @commandPane = atom.views.getView(new Command)
          @commandPane.setSource @project.sourceFile
          @commandPane.setCallbacks @accept, @hidePanes
          @showPane @commandPane
        @addCommands()

      detached: ->
        @off 'click', '#add-command-button'

      addCommands: ->
        @command_list.html('')
        for command in @project.getCommands()
          pane = new CommandInfoPane(command)
          up = (command) =>
            @project.moveCommand(command.name, -1)
          down = (command) =>
            @project.moveCommand(command.name, 1)
          edit = (command) =>
            c = new Command(command)
            c.oldname = c.name
            c.project = @project.projectPath
            @commandPane = atom.views.getView(c)
            @commandPane.sourceFile = @project.sourceFile
            @commandPane.setCallbacks((_command, oldname) =>
              @project.replaceCommand(oldname, _command)
            , @hidePanes)
            @showPane @commandPane
          remove = (command) =>
            @project.removeCommand(command.name)
          pane.setCallbacks up, down, edit, remove
          @command_list.append pane
