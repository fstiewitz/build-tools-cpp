{$$, View} = require 'atom-space-pen-views'

Outputs = require '../output/output'

MainPane = require './command-info-main-pane'
SavePane = require './command-info-save-pane'
ProfilePane = require './command-info-profile-pane'

module.exports =
  class InfoPane extends View

    @content: ->
      @div class: 'command', =>
        @div class: 'top', =>
          @div id: 'info', class: 'align', =>
            @div class: 'icon-triangle-right expander'
            @div id: 'name', outlet: 'name'
          @div id: 'options', class: 'align', =>
            @div class: 'icon-pencil'
            @div class: 'icon-triangle-up'
            @div class: 'icon-triangle-down'
            @div class: 'icon-x'
        @div class: 'info hidden', outlet: 'info'

    initialize: (@command) ->
      @panes = []
      @name.text(@command.name)
      @info.append @buildPane(MainPane)
      @info.append @buildPane(SavePane)
      @info.append @buildPane(ProfilePane)
      @initializeOutputModules()
      @addEventHandlers()

    setCallbacks: (@up, @down, @edit, @remove) ->

    addEventHandlers: ->
      @on 'click', '.icon-pencil', => @edit(@command)
      @on 'click', '.icon-triangle-up', => @up(@command)
      @on 'click', '.icon-triangle-down', => @down(@command)
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

    buildPane: (Element, name) ->
      if name?
        element = $$ ->
          @div class: 'inset-panel', =>
            @div class: 'panel-heading', "#{name}: active"
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
      for key in Object.keys(@command.output)
        continue unless @command.output[key]?
        @buildPane Outputs.modules[key]?.info, Outputs.modules[key]?.name ? key
