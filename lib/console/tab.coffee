TabView = require './tab-view'
TabItem = require './tab-item'

{Emitter} = require 'atom'

module.exports =
  class Tab
    constructor: (@command) ->
      @emitter = new Emitter
      @header = new TabItem(@command.project, @command.name, => @close())
      @view = new TabView
      @header.setHeader "#{@command.name} of #{@command.project}"
      @focus = null
      @console = null

    destroy: ->
      @emitter.dispose()
      @focus = null
      @console = null
      @header = null
      @view = null
      @title = null
      @command = null

    clear: ->
      @view.clear()
      @error = null
      @code = null

    setRunning: ->
      @header.setIcon 'sync'

    setError: (@error) ->
      @header.setIcon 'x'
      @code = -1
      @getHeader()

    setFinished: (@code) ->
      if @code is 0
        @header.setIcon 'check'
      else
        @header.setIcon 'x'
        @getHeader()

    setCancelled: ->
      @header.setIcon 'x'
      @code = -2
      @getHeader()

    unlock: ->
      @view.unlock()

    lock: ->
      @view.lock()

    printLine: (line) ->
      @view.printLine line

    finishConsole: ->
      @view.finishConsole()

    hasFocus: ->
      return true unless @console?
      this is @console.activeTab

    getHeader: ->
      @title ?= document.createElement 'span'
      @title.innerText = "#{@command.name} of #{@command.project}"
      return @title unless @code?
      if @code isnt 0
        s = document.createElement 'span'
        @title.innerText += ': '
        s.className = 'error'
        if @code > 0
          s.innerText = 'finished with exit code ' + @code
        else if @code is -1
          s.innerText = 'received ' + @error
        else
          s.innerText = 'aborted by user or package'
        @title.appendChild s
      return @title

    close: ->
      @emitter.emit 'close'

    onClose: (callback) ->
      @emitter.on 'close', callback
