Command = null
path = null
{View, TextEditorView} = require 'atom-space-pen-views'
Project = null

notify = (message, error) ->
  atom.notifications?.addError message
  console.log('build-tools: ' + message)
  console.log(error)

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

      constructor: (@projectPath, @config, @_save = null) ->
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
        @project?.destroy()
        @project = null

      getCommandByIndex: (id) ->
        new Promise((resolve, reject) =>
          reject("Could not load project file #{@config.file}") unless @project?
          p = @project.getCommandByIndex id
          p.then (command) ->
            resolve(command)
          p.catch (e) -> reject(e)
        )

      getCommandCount: ->
        new Promise((resolve, reject) =>
          reject("Could not load project file #{@config.file}") unless @project?
          p = @project.getCommandNameObjects()
          p.then (arr) -> resolve(arr.length)
          p.catch (e) -> reject(e)
        )

      getCommandNames: ->
        new Promise((resolve, reject) =>
          reject("Could not load project file #{@config.file}") unless @project?
          p = @project.getCommandNameObjects()
          p.then (commands) ->
            resolve(command.name for command in commands)
          p.catch (e) -> reject(e)
        )


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

      attached: ->
        @on 'click', '#apply', =>
          if (p = @path.getModel().getText()) isnt ''
            @project.config.file = p
            @project.config.overwrite = @find('#overwrite_wd').prop('checked')
            @project.save()
          else
            atom.notifications?.addError 'Path must not be empty'
