{$,View} = require 'atom-space-pen-views'
output = require './output'

module.exports =
  class ConsoleOutput extends View
    @content: ->
      @div class:'console', =>
        @div class: 'header', =>
          @div class: 'name bold', outlet: 'name'
          @div class: 'icon-close'
        @div class: 'output hidden', outlet: 'output'

    visible_items:
      header: false
      output: false
    lockoutput: false

    initialize: ->
      @on 'click','.icon-close', =>
        @hideBox()
      @on 'mousedown', '.header', @startResize
      return

    serialize: ->

    destroy: ->
      @detach()

    attach: ->
      atom.workspace.addBottomPanel({item: this})

    hideBox: ->
      @detach() if @visible_items.header
      @visible_items.header = false

    showBox: ->
      @attach() if not @visible_items.header
      @visible_items.header = true

    cancel: ->
      @hideBox()

    startResize: (e) => # pass in the mousedown event
      $(document).on 'mousemove', @resize
      $(document).on 'mouseup', @endResize
      @padding = $(document.body).height() - (e.clientY + @find('.output').height()) # calculate padding offset

    resize: ({pageY, which}) =>
      return @endResize() unless which is 1
      @find('.output').height($(document.body).height() - pageY - @padding) #includes padding offset

    endResize: =>
      $(document).off 'mousemove', @resize
      $(document).off 'mouseup', @endResize

    hideOutput: ->
      @find('.output').addClass('hidden')
      @visible_items.output = false

    showOutput: ->
      @find('.output').removeClass('hidden')
      @visible_items.output = true

    clear: ->
      @find('.output').text('')

    openFile: (element) ->
      lineno = parseInt($(this).attr('row'))
      linecol= parseInt($(this).attr('col'))
      if $(this).attr('name') isnt ''
        atom.workspace.open($(this).attr('name'),
          initialLine: lineno-1
          initialColumn: linecol-1
          )

    finishConsole: ->
      @find('.filelink').on 'click', @openFile

    printLine: (message) =>
      @showOutput() if !@lockoutput
      @output.append(message)
      @output.scrollTop(@output[0].scrollHeight)

    setHeader: (name) ->
      @name.html(name)

    lock: ->
      @lockoutput = true

    unlock: ->
      @lockoutput = false

    createOutput: (cmd) ->
      @Output ?= require './output'
      @stdout.destroy() if @stdout?
      @stderr.destroy() if @stdout?
      @stdout = new @Output(cmd, 'stdout', @printLine)
      @stderr = new @Output(cmd, 'stderr', @printLine)

    destroyOutput: ->
      @stdout.destroy() if @stdout?
      @stderr.destroy() if @stderr?
