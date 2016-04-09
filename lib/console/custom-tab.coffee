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
      @opener = null

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

    printLine: (line) ->
      @view.printLine line

    finishConsole: ->
      @view.finishConsole(@open)

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

    setOpener: (@opener) ->

    open: (element) =>
      return if @opener?(element)?
      lineno = parseInt(element.attr('row'))
      linecol = parseInt(element.attr('col'))
      if element.attr('name') isnt ''
        atom.workspace.open(element.attr('name'),
          initialLine: lineno - 1
          initialColumn: linecol - 1
        )
