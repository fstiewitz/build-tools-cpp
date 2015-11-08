Command = null
path = null
{View, TextEditorView} = require 'atom-space-pen-views'
Project = null

module.exports =

  name: 'Link to configuration file'
  singular: 'External Command'

  activate: (command, project) ->
    Command = command
    Project = project
    path = require 'path'

  deactivate: ->
    Command = null
    Project = null
    path = null

  model:
    class BuildToolsProjectExternal

      constructor: ([@projectPath], @config, @_save = null) ->
        return if @_save?
        file = path.resolve(@projectPath, @config.file)
        if not @config.overwrite
          @projectPath = path.dirname(file)
        try
          @project = new Project(@projectPath, file)
        catch
          @project = null

      save: ->
        @_save()

      destroy: ->
        @projectPath = null
        @config = null
        @_save = null
        return if @_save?
        @project?.destroy()
        @project = null

      getCommandByIndex: (id) ->
        new Promise((resolve, reject) =>
          throw new Error("Could not load project file #{@config.file}") unless @project?
          @project.getCommandByIndex(id).then resolve, reject
        )

      getCommandCount: ->
        new Promise((resolve, reject) =>
          throw new Error("Could not load project file #{@config.file}") unless @project?
          @project.getCommandNameObjects().then ((arr) -> resolve(arr.length)), reject
        )

      getCommandNames: ->
        new Promise((resolve, reject) =>
          throw new Error("Could not load project file #{@config.file}") unless @project?
          @project.getCommandNameObjects().then ((commands) -> resolve(command.name for command in commands)), reject
        )

  view:
    class BuildToolsProjectExternal extends View
      @content: ->
        @div class: 'inset-panel', =>
          @div class: 'top panel-heading', =>
            @div =>
              @span id: 'provider-name', class: 'inline-block panel-text icon icon-file-symlink-file'
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
            @div class: 'block checkbox', =>
              @input id: 'overwrite_wd', type: 'checkbox'
              @label =>
                @div class: 'settings-name', 'Overwrite working directory'
                @div =>
                  @span class: 'inline-block text-subtle', 'Execute command relative to '
                  @span class: 'inline-block text-highlight', 'this'
                  @span class: 'inline-block text-subtle', ' config file instead of the external one'

      initialize: (@project) ->
        @path.getModel().setText(@project.config.file ? '')
        @find('#overwrite_wd').prop('checked', @project.config.overwrite)

      destroy: ->
        @project = null

      attached: ->
        @on 'click', '#apply', =>
          if (p = @path.getModel().getText()) isnt ''
            @project.config.file = p
            @project.config.overwrite = @find('#overwrite_wd').prop('checked')
            @project.save()
          else
            atom.notifications?.addError 'Path must not be empty'
