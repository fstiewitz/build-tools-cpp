{$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
Providers = require '../provider/provider'
Project = require '../provider/project'

module.exports =
  class ConfigPane extends ScrollView
    @content: ->
      @div id: 'config', =>
        @div class: 'panel-heading', =>
          @span class: 'inline-block panel-text icon icon-database', 'Providers'
          @span id: 'add-provider', class: 'inline-block btn btn-sm icon icon-plus', 'Add provider'
        @div class: 'panel-body padded', outlet: 'provider_list'

    initialize: (@projectPath, @filePath) ->
      @model = new Project(@projectPath, @filePath, true)
      super

    destroy: ->
      @model.destroy()

    attached: ->
      @disposables = new CompositeDisposable
      context = []

      for key in Object.keys(Providers.modules)
        name = Providers.modules[key].name
        @disposables.add atom.commands.add '.build-settings',  "build-tools:add-#{name}".replace(/\ /g, '-'), => @model.addProvider key
        context.push label: "Add #{name}", command: "build-tools:add-#{name}".replace(/\ /g, '-')

      @disposables.add atom.contextMenu.add {
        '#add-provider': context
      }

      @on 'click', '#add-provider', (event) -> atom.contextMenu.showForEvent(event)

      @disposables.add @model.onSave @reload

      @reload()

    detached: ->
      @disposables.dispose()
      @provider_list.html('')

    setCallbacks: (@hidePanes, @showPane) ->

    reload: =>
      @provider_list.html('')
      for provider, index in @model.providers
        @provider_list.append @buildPane Providers.modules[provider.key].name, provider.view.element, index
        provider.view.setCallbacks @hidePanes, @showPane

    buildPane: (name, element, id) ->
      item = $(element)
      item.find('#provider-name').text(name)
      item.on 'click', '.config-buttons .icon-triangle-up', => @model.moveProviderUp(id)
      item.on 'click', '.config-buttons .icon-triangle-down', => @model.moveProviderDown(id)
      item.on 'click', '.config-buttons .icon-x', => @model.removeProvider id
      return element
