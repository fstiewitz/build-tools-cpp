{$, $$, View} = require 'atom-space-pen-views'

{CompositeDisposable} = require 'atom'

Modifiers = require '../modifier/modifier'
Outputs = require '../output/output'

Command = require '../provider/command'

MainPane = require './command-edit-main-pane'
ProfilePane = require './command-edit-profile-pane'

module.exports =
  class CommandPane extends View

    @content: ->
      @div class: 'commandview', =>
        @div class: 'buttons', =>
          @div class: 'btn btn-sm btn-error icon icon-x inline-block-tight', 'Cancel'
          @div class: 'btn btn-sm btn-primary icon icon-check inline-block-tight', 'Accept'
        @div class: '_panes', outlet: 'panes_view'

    initialize: (@command) ->

    setCallbacks: (@success_callback, @cancel_callback) ->

    detached: ->
      @disposables.dispose()
      for item in @panes
        item.view?.destroy?()
      @panes = null

    attached: ->
      @panes = []

      @panes.push @buildPane(new MainPane, 'General', 'icon-gear')
      @initializeModifierModules()
      @panes.push @buildPane(new ProfilePane, 'Highlighting', 'icon-plug')
      @initializeOutputModules()

      @addEventHandlers()
      @initializePanes()

    buildPane: (view, name, icon, key, desc = '', enabled) ->
      item = $$ ->
        @div class: 'inset-panel', =>
          @div class: 'panel-heading top', =>
            if key?
              @div class: 'checkbox', =>
                @input id: key, type: 'checkbox'
                @label =>
                  @div class: "settings-name icon #{icon}", name
                  @div =>
                    @span class: 'inline-block text-subtle', desc
            else
              @span class: "settings-name icon #{icon}", name
      item.append view.element if view?
      if key?
        item.find('input').prop('checked', enabled)
        if view?
          view.element.classList.add 'hidden' unless enabled and view?
          item.children()[0].children[0].children[0].onchange = ->
            if @checked
              @parentNode.parentNode.parentNode.children[1]?.classList.remove 'hidden'
            else
              @parentNode.parentNode.parentNode.children[1]?.classList.add 'hidden'
      @panes_view.append item
      return pane: item, view: view

    initializeModifierModules: ->
      for key in Object.keys(Modifiers.modules)
        continue unless Modifiers.activate(key) is true
        mod = Modifiers.modules[key]
        view = null
        view = new mod.edit if mod.edit?
        @panes.push @buildPane(view, "Modifier: #{mod.name}", 'icon-pencil', key, mod.description, @command.modifier?[key]?)

    initializeOutputModules: ->
      for key in Object.keys(Outputs.modules)
        continue unless Outputs.activate(key) is true
        mod = Outputs.modules[key]
        view = null
        view = new mod.edit if mod.edit?
        @panes.push @buildPane(view, "Output: #{mod.name}", 'icon-terminal', key, mod.description, @command.output?[key]?)

    addEventHandlers: ->
      @on 'click', '.checkbox label', (e) ->
        item = $(e.currentTarget.parentNode.children[0])
        item.prop('checked', not item.prop('checked'))

      @on 'click', '.buttons .icon-x', @cancel
      @on 'click', '.buttons .icon-check', @accept

      @disposables = new CompositeDisposable

      @disposables.add atom.commands.add @element,
        'core:confirm': @accept
        'core:cancel': @cancel

    initializePanes: ->
      for {view} in @panes
        if @command.oldname?
          command = @command
        else
          command = null
        view?.set command

    accept: (event) =>
      @cancel event

    cancel: (event) =>
      @cancel_callback?()
      event.stopPropagation()
