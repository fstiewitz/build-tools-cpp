Tab = require './tab'
CustomTab = require './custom-tab'

{Emitter} = require 'atom'

module.exports =
  class Console
    constructor: ->
      @tabs = {}
      @emitter = new Emitter
      @activeTab = null

    destroy: ->
      @emitter.dispose()
      for k in Object.keys(@tabs)
        for k2 in Object.keys(@tabs[k])
          @removeTab @tabs[k][k2]
      @tabs = {}
      @emitter = null

    getTab: (command) ->
      return tab if (tab = @tabs[command.project]?[command.name])?
      @createTab(command)

    getCustomTab: (name) ->
      return tab if (tab = @tabs['custom']?[name])?
      @createCustomTab name

    createTab: (command) ->
      @tabs[command.project] ?= {}
      tab = @tabs[command.project][command.name] = new Tab(command)
      tab.onClose =>
        @removeTab tab
      tab.focus = =>
        @focusTab tab
      tab.console = this
      @emitter.emit 'add', tab
      return tab

    createCustomTab: (name) ->
      @tabs['custom'] ?= {}
      tab = @tabs.custom[name] = new CustomTab(name)
      tab.onClose =>
        @removeTab tab
      tab.focus = =>
        @focusTab tab
      tab.console = this
      @emitter.emit 'add', tab
      return tab

    removeTab: (tab) ->
      @emitter.emit 'remove', tab
      @activeTab = null if tab is @activeTab
      if tab.command?
        delete @tabs[tab.command.project][tab.command.name]
      else
        delete @tabs.custom[tab.name]
      tab.destroy()

    focusTab: (tab) ->
      @activeTab = tab
      @emitter.emit 'focus', tab

    onFocusTab: (callback) ->
      @emitter.on 'focus', callback

    onCreateTab: (callback) ->
      @emitter.on 'add', callback

    onRemoveTab: (callback) ->
      @emitter.on 'remove', callback
