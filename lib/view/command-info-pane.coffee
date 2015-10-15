{$$, View} = require 'atom-space-pen-views'

Outputs = require '../output/output'
Modifiers = require '../modifier/modifier'

MainPane = require './command-info-main-pane'
ProfilePane = require './command-info-profile-pane'

module.exports =
  class InfoPane extends View

    @content: ->
      @div class: 'command inset-panel', =>
        @div class: 'top panel-heading', =>
          @div id: 'info', class: 'align', =>
            @div class: 'icon-triangle-right expander'
            @div id: 'name', outlet: 'name'
          @div id: 'options', class: 'align', =>
            @div class: 'icon-pencil'
            @div class: 'icon-triangle-up move-up'
            @div class: 'icon-triangle-down move-down'
            @div class: 'icon-x'
        @div class: 'info hidden panel-body', outlet: 'info'

    initialize: (@command) ->
      @panes = []
      @name.text(@command.name)
      @info.append @buildPane(MainPane, 'General', false)
      @initializeModifierModules()
      @info.append @buildPane(ProfilePane, 'Highlighting', false)
      @initializeOutputModules()
      @addEventHandlers()

    setCallbacks: (@up, @down, @edit, @remove) ->

    addEventHandlers: ->
      @on 'click', '.icon-pencil', => @edit(@command)
      @on 'click', '.move-up', => @up(@command)
      @on 'click', '.move-down', => @down(@command)
      @on 'click', '.icon-x', => @remove(@command)
      @on 'click', '.expander', ({currentTarget}) ->
        if currentTarget.classList.contains 'icon-triangle-right'
          currentTarget.classList.remove 'icon-triangle-right'
          currentTarget.classList.add 'icon-triangle-down'
          currentTarget.parentNode.parentNode.parentNode.children[1].classList.remove 'hidden'
        else
          currentTarget.classList.add 'icon-triangle-right'
          currentTarget.classList.remove 'icon-triangle-down'
          currentTarget.parentNode.parentNode.parentNode.children[1].classList.add 'hidden'

    buildPane: (Element, name, active = true) ->
      if name?
        element = $$ ->
          @div class: 'inset-panel', =>
            @div class: 'panel-heading', name + if active then ': active' else ''
            if Element?
              @div class: 'panel-body padded'
      else
        element = $$ ->
          @div class: 'inset-panel', =>
            @div class: 'panel-body padded'
      if Element?
        @panes.push new Element(@command)
        element.find('.panel-body').append @panes[@panes.length - 1].element
      @info.append element

    initializeOutputModules: ->
      for key in Object.keys(@command.output ? {})
        continue unless Outputs.activate(key) is true
        continue if Outputs.modules[key].private
        @buildPane Outputs.modules[key].info, 'Output: ' + Outputs.modules[key].name

    initializeModifierModules: ->
      for key in Object.keys(@command.modifier ? {})
        continue unless Modifiers.activate(key) is true
        continue if Modifiers.modules[key].private
        @buildPane Modifiers.modules[key].info, 'Modifier: ' + Modifiers.modules[key].name
