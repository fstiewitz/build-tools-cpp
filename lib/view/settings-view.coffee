{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
ConfigPane = require './config-pane'

module.exports =
  class SettingsView extends View
    @content: ->
      @div class: 'build-settings pane-item', tabindex: -1

    initialize: (@projectPath, @filePath) ->

    getUri: ->
      @filePath

    getTitle: ->
      'Build Config: ' + @projectPath

    getIconName: ->
      'tools'

    attached: ->
      @configPane = new ConfigPane(@projectPath, @filePath)
      @model = @configPane.model
      @configPane.setCallbacks @hidePanes, @showPane
      @html('')
      @append @configPane

    detached: ->
      @html('')
      @configPane.destroy()
      @configPane = null
      @model = null

    hidePanes: =>
      @html('')
      @append @configPane

    showPane: (pane) =>
      @html('')
      @append pane
