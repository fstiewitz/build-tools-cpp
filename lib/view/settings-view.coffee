{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
ConfigPane = require './config-pane'

module.exports =
  class SettingsView extends View
    @content: ->
      @div class: 'build-settings pane-item', tabindex: -1

    initialize: (@projectPath, @filePath) ->
      @configPane = new ConfigPane(@projectPath, @filePath)
      @configPane.setCallbacks @hidePanes, @showPane

    getUri: ->
      @filePath

    getTitle: ->
      'Build Config: ' + @projectPath

    getIconName: ->
      'tools'

    attached: ->
      @html('')
      @append @configPane

    detached: ->
      @detach()
      @html('')

    hidePanes: =>
      @html('')
      @append @configPane

    showPane: (pane) =>
      @html('')
      @append pane
