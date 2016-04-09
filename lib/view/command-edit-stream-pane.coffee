{$, $$, TextEditorView, View} = require 'atom-space-pen-views'

{CompositeDisposable} = require 'atom'

Modifiers = require '../stream-modifiers/modifiers'

nice =
  stdout: 'Standard Output Stream (stdout)'
  stderr: 'Standard Error Stream (stderr)'

module.exports =
  class StreamPane extends View

    @content: ->
      @div class: 'stream-modifier panel-body', =>
        @div class: 'block', =>
          @div class: 'panel-heading', =>
            @span class: 'inline-block panel-text icon icon-plug', outlet: 'heading'
            @span id: 'add-modifier', class: 'inline-block btn btn-sm icon icon-plus', 'Add Modifier'
          @div class: 'panel-body padded', outlet: 'panes_view'

    attached: ->
      @disposables = new CompositeDisposable
      @panes = []

    detached: ->
      @removeEventHandlers()
      for item in @panes
        item.view?.destroy?()
      @panes = null
      @panes_view.empty()

    set: (@command, @stream, @sourceFile) ->
      @heading.text(nice[@stream])
      @loadAddCommands(stream)
      @loadModifierModules(@command[stream].pipeline) if @command?
      @addEventHandlers()

    get: (command, stream) ->
      for {view} in @panes
        return e if (e = view.get command, stream)?
      return null

    loadAddCommands: (stream) ->
      @addClass stream

      context = []
      for key in Object.keys(Modifiers.modules).sort()
        name = Modifiers.modules[key].name
        @disposables.add atom.commands.add this[0], "build-tools:add-#{key}", ((k) =>
          => @addModifier k
        )(key)
        context.push label: name, command: "build-tools:add-#{key}"

      contextMenu = {}
      contextMenu[".#{stream} #add-modifier"] = context

      @disposables.add atom.contextMenu.add contextMenu

    loadModifierModules: (pipeline) ->
      for {name, config} in pipeline
        @addModifier name, config

    addModifier: (name, config) ->
      return unless Modifiers.activate(name) is true
      mod = Modifiers.modules[name]
      return if mod.private
      {view} = @buildPane(new mod.edit,
        mod.name,
        'icon-eye',
        name,
        mod.description,
        config
      )
      @initializePane view, config

    initializePane: (view, config) ->
      view?.set? @command, config, @stream, @sourceFile

    buildPane: (view, name, icon, key, desc = '', config) ->
      item = $$ ->
        @div class: 'inset-panel', =>
          @div class: 'panel-heading top module', =>
            @div class: 'align', =>
              @div class: "settings-name icon #{icon}", name
              @div =>
                @span class: 'inline-block text-subtle', desc
            @div class: 'align', =>
              @div class: 'icon-triangle-up'
              @div class: 'icon-triangle-down'
              @div class: 'icon-x'
      item.append view.element if view.element?
      item.on 'click', '.panel-heading .align .icon-triangle-up', (event) =>
        for pane, index in @panes
          if pane.key is key
            @moveModifierUp(index)
            event.stopPropagation()
            break
      item.on 'click', '.panel-heading .align .icon-triangle-down', (event) =>
        for pane, index in @panes
          if pane.key is key
            @moveModifierDown(index)
            event.stopPropagation()
            break
      item.on 'click', '.panel-heading .align .icon-x', (event) =>
        for pane, index in @panes
          if pane.key is key
            @removeModifier index
            event.stopPropagation()
            break
      @panes_view.append item
      @panes.push pane: item, view: view, key: key, config: config
      return pane: item, view: view, config: config

    moveModifierUp: (index) ->
      return false if (index is 0) or (index > Object.keys(Modifiers.modules).length)
      e = @panes.splice(index, 1)[0]
      @panes.splice(index - 1, 0, e)
      $(@panes_view.children()[index - 1]).before e.pane

    moveModifierDown: (index) ->
      return false if (index >= Object.keys(Modifiers.modules).length)
      e = @panes.splice(index + 1, 1)[0]
      @panes.splice(index, 0, e)
      $(@panes_view.children()[index]).before e.pane

    removeModifier: (index) ->
      return false if index > @panes.length
      [{pane}] = @panes.splice(index, 1)
      pane.remove()

    addEventHandlers: ->
      @on 'click', '#add-modifier', (event) -> atom.contextMenu.showForEvent(event)

    removeEventHandlers: ->
      @off 'click', '#add-modifier'
      @disposables.dispose()
