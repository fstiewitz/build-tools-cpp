{$$, View} = require 'atom-space-pen-views'

Outputs = require '../output/output'

Command = require '../command'

MainPane = require './command-edit-main-pane'
SavePane = require './command-edit-save-pane'
ProfilePane = require './command-edit-profile-pane'

module.exports =
  class CommandPane extends View

    @content: ->
      @div class: 'commandview', =>
        @div class: 'inset-panel', outlet: 'general', =>
          @div class: 'panel-heading settings-name icon icon-gear', 'General'
        @div class: 'inset-panel', outlet: 'save_all', =>
          @div class: 'panel-heading settings-name icon icon-triangle-right', 'Modifier: Save all'
        @div class: 'inset-panel', outlet: 'profiles', =>
          @div class: 'panel-heading settings-name icon icon-plug', 'Highlighting'
        @div outlet: 'output_modules'
        @div class: 'buttons', =>
          @div class: 'btn btn-error icon icon-x inline-block-tight', 'Cancel'
          @div class: 'btn btn-primary icon icon-check inline-block-tight', 'Accept'

    initialize: (@command, @success_callback, @cancel_callback) ->
      @panes = []

      @panes.push type: 'main', pane: @general, view: new MainPane
      @panes.push type: 'main', pane: @save_all, view: new SavePane
      @panes.push type: 'main', pane: @profiles, view: new ProfilePane

      @general.append @panes[0]
      @save_all.append @panes[1]
      @profiles.append @panes[2]

      @initializeOutputModules()
      @addEventHandler()
      @initializePanes()

    destroy: ->
      @disposables.dispose()
      for item in @panes
        item.view?.destroy?()
      @panes = null

    initializeOutputModules: ->
      for key in Object.keys(Outputs.modules)
        continue if Outputs.modules[key].private
        pane = $$ ->
          @div class: 'inset-panel', =>
            @div class: 'pane-heading output-module', =>
              @input id: key, type: 'checkbox', checked: @command.output[key]?
              @div class: 'inline-block icon icon-terminal', Output.modules[key].name
        edit = null
        if Outputs.modules[key].edit?
          pane.append (edit = new Outputs.modules[key].edit)
          pane.find('.panel-body').addClass('hidden') unless @command.output[key]?
        @panes.push type: 'output', pane: pane, view: edit

    addEventHandler: ->
      @on 'click', '.checkbox label', (e) ->
        item = $(e.currentTarget.parentNode.children[0])
        item.prop('checked', not item.prop('checked'))

      @on 'click', '.output-module', ({currentTarget}) ->
        item = $(currentTarget.children[0])
        item.prop('checked', not item.prop('checked'))
        if currentTarget.parentNode.children.length is 2
          if item.prop('checked')
            currentTarget.parentNode.children[1].classList.remove 'hidden'
          else
            currentTarget.parentNode.children[1].classList.add 'hidden'

      @on 'click', '.buttons .icon-x', @cancel
      @on 'click', '.buttons .icon-check', @accept

      @disposables.add atom.commands.add @element,
        'core:confirm': @accept
        'core:cancel': @cancel

    initializePanes: ->
      for item in @panes
        item.view.set @command

    accept: (event) =>
      c = new Command
      for item in @panes
        if item.type is 'main'
          return @cancel(event) unless item.view.get c
        else if item.type is 'output'
          continue unless item.pane.find('input').prop('checked')
          c.output[item.pane.find('input').id] = {}
          return @cancel(event) unless item.view.get c
      @success_callback c
      @cancel event

    cancel: (event) =>
      @cancel_callback()
      event.stopPropagation()
