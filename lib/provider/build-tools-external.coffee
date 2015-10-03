Command = null
CSON = null
path = null
{View, TextEditorView} = require 'atom-space-pen-views'

notify = (message, error) ->
  atom.notifications?.addError message
  console.log('build-tools: ' + message)
  console.log(error)

module.exports =

  name: 'External Custom Commands'
  singular: 'External Custom Command'

  activate: (command) ->
    Command = command
    path = require 'path'
    CSON = require 'season'

  deactivate: ->
    Command = null
    CSON = null
    path = null

  model:
    class BuildToolsProjectExternal

      constructor: (@projectPath, @config, @_save = null) ->
        return if @_save?
        try
          @commands = []
          data = CSON.readFileSync path.resolve(@projectPath, @config.file)
          for provider in data.providers
            if provider.key is 'bt' and provider.config.commands?
              for command in provider.config.commands
                @commands.push new Command(command)
        catch error
          notify "Could not read from #{@config.file}", error

      save: ->
        @_save()

      getCommandByIndex: (id) ->
        @commands[id]

      getCommandCount: ->
        @commands.length

      getCommandNames: ->
        (c.name for c in @commands)

  view:
    class BuildToolsProjectExternal extends View
      @content: ->
        @div class: 'inset-panel', =>
          @div class: 'top panel-heading', =>
            @div =>
              @span id: 'provider-name', class: 'inline-block panel-text icon icon-file-symlink-file', name
              @span id: 'apply', class: 'inline-block btn btn-xs icon icon-check', 'Apply'
            @div class: 'config-buttons align', =>
              @div class: 'icon-triangle-up'
              @div class: 'icon-triangle-down'
              @div class: 'icon-x'
          @div class: 'panel-body padded', =>
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'File Location'
                @div =>
                  @span class: 'inline-block text-subtle', 'Path to .build-tools.cson file'
              @subview 'path', new TextEditorView(mini: true)

      initialize: (@project) ->
        @path.getModel().setText(@project.config.file ? '')

      attached: ->
        @on 'click', '#apply', =>
          if (p = @path.getModel().getText()) isnt ''
            @project.config.file = p
            @project.save()
          else
            atom.notifications?.addError 'Path must not be empty'
