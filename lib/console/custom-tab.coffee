TabView = require './tab-view'
TabItem = require './tab-item'

{Emitter} = require 'atom'

module.exports =
  class Tab
    constructor: (@name) ->
      @emitter = new Emitter
      @header = new TabItem('custom', @name, => @close())
      @view = new TabView
      @header.setHeader "#{@name}"

    destroy: ->
      @emitter.dispose()

    clear: ->
      @view.clear()

    setIcon: (icon) ->
      @header.setIcon icon

    setHeader: (header) ->
      @header.setHeader header
      @title ?= document.createElement 'span'
      @title.innerText = header

    unlock: ->
      @view.unlock()

    lock: ->
      @view.lock()

    printLine: (line) ->
      @view.printLine line

    finishConsole: ->
      @view.finishConsole()

    hasFocus: ->
      this is @console.activeTab

    getHeader: ->
      return @title if @title?
      @title = document.createElement 'span'
      @title.innerText = "#{@name}"
      return @title

    close: ->
      @emitter.emit 'close'

    onClose: (callback) ->
      @emitter.on 'close', callback
