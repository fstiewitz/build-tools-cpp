{$, View} = require 'atom-space-pen-views'

module.exports =
  class ConsoleOutput extends View
    @content: ->
      @div class: 'console', =>
        @div class: 'header', =>
          @div class: 'titlebar', =>
            @progress class: 'inline-block', outlet: 'progress'
            @div class: 'name bold', outlet: 'name'
          @div class: 'icons', =>
            @div class: 'icon-link-external hidden'
            @div class: 'icon-x'
        @div class: 'output hidden', outlet: 'output'

    visible_items:
      header: false
      output: false
    lockoutput: false

    initialize: ->
      @on 'click', '.icon-x', =>
        @hideBox()
      @on 'click', '.icon-link-external', =>
        @showExternal()
      @on 'mousedown', '.header', @startResize
      @timeout = null
      @progress.prop('max', '100')
      @progress.prop('value', '100')

    destroy: ->
      @hideBox()
      @panel?.destroy()
      @panel = null
      @timeout = null

    detach: ->
      @panel?.hide()

    attach: ->
      @panel ?= atom.workspace.addBottomPanel({item: this})
      @panel.show()

    hideBox: ->
      @detach() if @visible_items.header
      @visible_items.header = false

    showBox: ->
      @attach() if not @visible_items.header
      @showOutput() if @find('.output').text() isnt ''
      @visible_items.header = true

    showExternal: ->
      atom.workspace.open(null).then (editor) =>
        editor.setText @buildText()

    buildText: ->
      s = []
      for child in @output.children()
        s.push child.textContent
      s.join('\n')

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
      @hideOutput()
      @find('.output').text('')
      @find('.icon-link-external').addClass 'hidden'
      clearTimeout @timeout if @timeout?

    openFile: (element) ->
      lineno = parseInt($(this).attr('row'))
      linecol = parseInt($(this).attr('col'))
      if $(this).attr('name') isnt ''
        atom.workspace.open($(this).attr('name'),
          initialLine: lineno - 1
          initialColumn: linecol - 1
          )

    finishConsole: (exitcode) ->
      @find('.icon-link-external').removeClass 'hidden'
      @find('.filelink').on 'click', @openFile
      if @cmd.output['console'].close_success and exitcode is 0
        t = atom.config.get('build-tools.CloseOnSuccess')
        if t < 1
          @hideBox()
        else
          @timeout = setTimeout( =>
            @hideBox()
            @timeout = null
          , t * 1000)

    setCommand: (@cmd) ->

    printLine: (message) =>
      @showOutput() if not @lockoutput and @visible_items.output is false
      @output.append(message)
      @output.scrollTop(@output[0].scrollHeight)
      @output[0].children[@output[0].children.length - 1]

    setHeader: (name) ->
      @name.html(name)

    lock: ->
      @lockoutput = true

    unlock: ->
      @lockoutput = false

    setQueueCount: (@queue) ->
      if @queue is 1
        @progress.prop('max', '1')
        @progress.removeAttr('value')
      else
        @progress.prop('max', "#{@queue}")
        @progress.prop('value', '0')

    setQueueLength: (length) ->
      p = @queue - length
      @progress.prop('value', "#{p}")
