{ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
Providers = require '../provider/provider'

module.exports =
  class SettingsView extends ScrollView
    @content: ->
      @div class: 'build-settings pane-item', tabindex: -1, =>
        @div class: 'panel-heading', =>
          @span class: 'inline-block panel-text icon icon-database', 'Providers'
          @span id: 'add-provider', class: 'inline-block btn btn-sm icon icon-plus', 'Add provider'
        @div class: 'panel-body padded', outlet: 'provider_list'

    initialize: (@model) ->
      super
      @disposables = new CompositeDisposable

      context = []
      for key in Object.keys(Providers.modules)
        name = Providers.modules[key].name
        @disposables.add atom.commands.add '.build-settings',  "build-tools:add-#{name}".replace(/\ /g, '-'), ({type}) -> console.log type
        context.push label: "Add #{name}", command: "build-tools:add-#{name}".replace(/\ /g, '-')

      @disposables.add atom.contextMenu.add {
        '#add-provider': context
      }


    getUri: ->
      @model.filePath

    getTitle: ->
      'Build Config: ' + @model.projectPath

    getIconName: ->
      'tools'

    detached: ->
      @disposables.dispose()
