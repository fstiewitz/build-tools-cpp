TabView = require './tab-view'
TabItem = require './tab-item'

{Emitter} = require 'atom'

module.exports =
  class Tab
    constructor: (@command) ->
      @emitter = new Emitter
      @destroyed = false
      @header = new TabItem(@command.project, @command.name, => @close())
      @view = new TabView
      @header.setHeader "#{@command.name} of #{@command.project}"
      @focus = null
      @console = null
      @input = null

    destroy: ->
      @destroyed = true
      @emitter.dispose()
      @input = null
      @focus = null
      @console = null
      @header = null
      @view = null
      @title = null
      @command = null

    clear: ->
      return if @destroyed
      @view.clear()
      @error = null
      @code = null
      @signal = null

    setInput: (@input) ->

    setRunning: ->
      return if @destroyed
      @header.setIcon 'sync'

    setError: (@error) ->
      return if @destroyed
      @header.setIcon 'x'
      @code = -1
      @getHeader()

    setFinished: (status) ->
      return if @destroyed
      @code = status.exitcode
      @signal = status.signal
      if @code is 0
        @header.setIcon 'check'
      else
        @header.setIcon 'x'
        @getHeader()

    setCancelled: ->
      return if @destroyed
      @header.setIcon 'x'
      @code ?= -2
      @getHeader()

    newLine: ->
      return if @destroyed
      @view.printLine '<div></div>'

    scroll: ->
      return if @destroyed
      @view.scroll()

    finishConsole: ->
      return if @destroyed
      @view.finishConsole()

    hasFocus: ->
      return true unless @console?
      this is @console.activeTab

    getHeader: ->
      return if @destroyed
      @title ?= document.createElement 'span'
      @title.innerText = "#{@command.name} of #{@command.project}"
      return @title unless @code?
      if @code isnt 0
        s = document.createElement 'span'
        @title.innerText += ': '
        s.className = 'error'
        if @signal isnt null
          s.innerText = 'received ' + @signal
        else if @code > 0
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
