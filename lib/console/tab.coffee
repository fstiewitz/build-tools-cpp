TabView = require './tab-view'
TabItem = require './tab-item'

{Emitter} = require 'atom'

module.exports =
  class Tab
    constructor: (@command) ->
      @emitter = new Emitter
      @header = new TabItem(@command.project, @command.name, => @close())
      @view = new TabView
      @timeout = null
      @header.setHeader "#{@command.name} of #{@command.project}"

    destroy: ->
      @emitter.dispose()

    clear: ->
      @view.clear()
      @error = null
      @code = null
      clearTimeout @timeout if @timeout?

    setRunning: ->
      @header.setSpinner()

    setError: (@error) ->
      @header.setIcon 'x'
      @code = -1

    setFinished: (@code) ->
      if @code is 0
        @header.setIcon 'check'
      else
        @header.setIcon 'x'
      @activateCallback()

    setCancelled: ->
      @header.setIcon 'x'
      @code = -2

    unlock: ->
      @view.unlock()

    lock: ->
      @view.lock()

    printLine: (line) ->
      @view.printLine line

    finishConsole: ->
      @view.finishConsole()

    activateCallback: ->
      if @command.output['console'].close_success and @code is 0
        t = atom.config.get('build-tools.CloseOnSuccess')
        if t < 1
          @close()
        else
          @timeout = setTimeout( =>
            @close()
            @timeout = null
          , t * 1000)

    getHeader: ->
      h = document.createElement 'span'
      h.innerText = "#{@command.name} of #{@command.project}"
      return h unless @code?
      if @code isnt 0
        s = document.createElement 'span'
        h.innerText += ': '
        s.className = 'error'
        if @code > 0
          s.innerText = 'finished with exit code ' + @code
        else if @code is -1
          s.innerText = 'received ' + @error
        else
          s.innerText = 'aborted by user or package'
        h.appendChild s
      return h

    close: ->
      @emitter.emit 'close'

    onClose: (callback) ->
      @emitter.on 'close', callback
