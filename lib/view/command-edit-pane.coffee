{$, $$, View} = require 'atom-space-pen-views'

{CompositeDisposable} = require 'atom'

Modifiers = require '../modifier/modifier'
Outputs = require '../output/output'

Command = require '../provider/command'

MainPane = require './command-edit-main-pane'
HighlightingPane = require './command-edit-highlighting-pane'

module.exports =
  class CommandPane extends View

    @content: ->
      @div class: 'commandview', =>
        @div class: 'buttons', =>
          @div class: 'btn btn-sm btn-error icon icon-x inline-block-tight', 'Cancel'
          @div class: 'btn btn-sm btn-primary icon icon-check inline-block-tight', 'Accept'
        @div class: '_panes', outlet: 'panes_view'

    initialize: (@command) ->
      @blacklist = []

    destroy: ->
      @blacklist = null
      @success_callback = null
      @cancel_callback = null

    setCallbacks: (@success_callback, @cancel_callback) ->

    setBlacklist: (@blacklist) ->

    setSource: (@sourceFile) ->

    detached: ->
      @removeEventHandlers()
      for item in @panes
        item.view?.destroy?()
      @panes = null
      @panes_view.empty()

    attached: ->
      @panes = []

      @buildPane(new MainPane, 'General', 'icon-gear') unless 'general' in @blacklist
      @initializeModifierModules() unless 'modifiers' in @blacklist
      @buildPane(new HighlightingPane, 'Highlighting', 'icon-eye') unless 'highlighting' in @blacklist
      @initializeOutputModules() unless 'outputs' in @blacklist

      @addEventHandlers()
      @initializePanes()

    buildPane: (view, name, icon, key, desc = '', enabled, moveable = false) ->
      item = $$ ->
        @div class: 'inset-panel', =>
          c = 'panel-heading top'
          c += ' module' if key?
          @div class: c, =>
            if key?
              @div class: 'checkbox align', =>
                @input id: key, type: 'checkbox'
                @label =>
                  @div class: "settings-name icon #{icon}", name
                  @div =>
                    @span class: 'inline-block text-subtle', desc
              if moveable
                @div class: 'align', =>
                  @div class: 'icon-triangle-up'
                  @div class: 'icon-triangle-down'
            else
              @span class: "settings-name icon #{icon}", name
      item.append view.element if view.element?
      if key?
        item.find('input').prop('checked', enabled)
        if view.element?
          view.element.classList.add 'hidden' unless enabled
          item.children()[0].children[0].children[0].onchange = ->
            if @checked
              @parentNode.parentNode.parentNode.children[1]?.classList.remove 'hidden'
            else
              @parentNode.parentNode.parentNode.children[1]?.classList.add 'hidden'
        if moveable
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
      @panes_view.append item
      @panes.push pane: item, view: view, key: key
      return pane: item, view: view

    initializeModifierModules: ->
      @modifier_count = 0
      for key in Object.keys(@command.modifier ? {})
        continue if key in @blacklist
        continue unless Modifiers.activate(key) is true
        mod = Modifiers.modules[key]
        continue if mod.private
        @modifier_count = @modifier_count + 1
        @buildPane(new mod.edit, "Modifier: #{mod.name}", 'icon-pencil', key, mod.description, @command.modifier?[key]?, true)

      if Object.keys(@command.modifier ? {}).length is 0
        rest = Object.keys(Modifiers.modules)
      else
        rest = Object.keys(Modifiers.modules).filter (key) =>
          not (key in Object.keys(@command.modifier ? {}))

      for key in rest
        continue if key in @blacklist
        continue unless Modifiers.activate(key) is true
        mod = Modifiers.modules[key]
        continue if mod.private
        @modifier_count = @modifier_count + 1
        @buildPane(new mod.edit, "Modifier: #{mod.name}", 'icon-pencil', key, mod.description, @command.modifier?[key]?, true)

    initializeOutputModules: ->
      for key in Object.keys(Outputs.modules)
        continue if key in @blacklist
        continue unless Outputs.activate(key) is true
        mod = Outputs.modules[key]
        continue if mod.private
        @buildPane(new mod.edit, "Output: #{mod.name}", 'icon-terminal', key, mod.description, @command.output?[key]?)

    moveModifierUp: (index) ->
      return false if (index is 1) or (index > @modifier_count)
      e = @panes.splice(index, 1)[0]
      @panes.splice(index - 1, 0, e)
      $(@panes_view.children()[index - 1]).before e.pane

    moveModifierDown: (index) ->
      return false if (index >= @modifier_count)
      e = @panes.splice(index + 1, 1)[0]
      @panes.splice(index, 0, e)
      $(@panes_view.children()[index]).before e.pane

    removeEventHandlers: ->
      @off 'click', '.checkbox label'
      @off 'click', '.buttons .icon-x'
      @off 'click', '.buttons .icon-check'
      @disposables.dispose()

    addEventHandlers: ->
      @on 'click', '.checkbox label', (e) ->
        item = $(e.currentTarget.parentNode.children[0])
        item.prop('checked', not item.prop('checked'))
        item[0].onchange?()

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
        view?.set? command, @sourceFile

    accept: (event) =>
      c = new Command
      c.project = @command.project
      for {pane, view, key} in @panes
        if (p = pane.children()[0].children[0].children[0])?
          if p.checked
            if (ret = view.get(c))?
              atom.notifications?.addError "Error in '#{key}' module: #{ret}"
              event.stopPropagation()
              return
        else
          if (ret = view.get(c))?
            atom.notifications?.addError ret
            event.stopPropagation()
            return
      @success_callback c, @command.oldname
      @cancel event

    cancel: (event) =>
      @cancel_callback?()
      event.stopPropagation()
