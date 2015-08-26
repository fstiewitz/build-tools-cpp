{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_p = require 'path'

ProjectPane = null
CommandPane = null

module.exports =
  class LocalSettingsView extends View
    projectpane: null
    commandpane: null
    activepane: null

    @content: ->
      @div class: 'settings pane-item', tabindex: -1, =>
        @div class: 'panel padded', outlet: 'pane'

    initialize: ({@uri, @projects, @project, @profiles}) ->
      ProjectPane ?= require './project-pane'
      CommandPane ?= require './command-pane'
      @projectpane = new ProjectPane(@projects, @profiles, (arg0, arg1, arg2, arg3) =>
        @showCommandPane()
        @commandpane.show arg0, arg1, arg2, arg3
      )
      @commandpane = new CommandPane(@projectpane.editccb, @hideCommandPane)
      @reload()
      return

    destroy: ->
      @detach()
      @projectpane?.destroy()
      @projectpane = null
      @commandpane?.destroy()
      @commandpane = null
      @projects = null
      @project = null
      @profiles = null
      @activepane = null

    attached: ->
      @filechange = @project?.onFileChange @reload

    detached: ->
      @filechange?.dispose()
      @filechange = null

    getURI: ->
      @uri

    getTitle: ->
      'Local Build Tools Settings'

    getIconName: ->
      'tools'

    showProjectPane: ->
      if @activepane isnt @projectpane
        @activepane?.detach()
        @pane.html @projectpane
        @activepane = @projectpane

    showCommandPane: ->
      if @activepane isnt @commandpane
        @activepane?.detach()
        @pane.html @commandpane
        @activepane = @commandpane

    hideCommandPane: =>
      @showProjectPane()

    reload: =>
      return unless @projects?
      @projectpane.hideModals()
      @showProjectPane()
      @projectpane.setContent @project, _p.resolve(@uri, '..')
