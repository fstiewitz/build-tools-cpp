{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
StreamPane = require './command-edit-stream-pane'

module.exports =
  class HighlightingPane extends View

    @content: ->
      @div class: 'panel-body', =>
        @div class: 'padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Output Streams'
              @div =>
                @span class: 'inline-block text-subtle', 'Configure standard output/error stream'
            @select class: 'form-control', outlet: 'streams', =>
              @option value: 'none', 'Disable all streams'
              @option value: 'no-stdout', 'No stdout'
              @option value: 'no-stderr', 'No stderr'
              @option value: 'stderr-in-stdout', 'Redirect stderr in stdout'
              @option value: 'stdout-in-stderr', 'Redirect stdout in stderr'
              @option value: 'both', 'Display all streams'
              @option value: 'pty-stdout', 'Use pty.js + redirect stderr in stdout'
              @option value: 'pty-stderr', 'Use pty.js + redirect stdout in stderr'
          @div class: 'block hidden', outlet: 'pty', =>
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'Number of Rows'
                @div =>
                  @span class: 'inline-block text-subtle', 'Dimensions of pseudo terminal (for pty.js)'
              @subview 'pty_rows', new TextEditorView(mini: true, placeholderText: '25')
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'Number of Columns'
                @div =>
                  @span class: 'inline-block text-subtle', 'Dimensions of pseudo terminal (for pty.js)'
              @subview 'pty_cols', new TextEditorView(mini: true, placeholderText: '80')
        @div class: 'stream', outlet: 'stdout'
        @div class: 'stream', outlet: 'stderr'

    attached: ->
      @_stdout = new StreamPane
      @_stderr = new StreamPane
      @stdout.append @_stdout
      @stderr.append @_stderr
      @streams.on 'change', @pty, ({data, currentTarget}) ->
        value = currentTarget.children[currentTarget.selectedIndex].value
        if value.startsWith 'pty'
          data.removeClass 'hidden'
        else
          data.addClass 'hidden'

    detached: ->
      @streams.off 'change'
      @_stdout.remove()
      @_stderr.remove()
      @_stdout = null
      @_stderr = null
      @stdout.empty()
      @stderr.empty()

    set: (command, sourceFile) ->
      @_stdout.set command, 'stdout', sourceFile
      @_stderr.set command, 'stderr', sourceFile
      if command?
        @setStreamOption command.environment.config.stdoe
      else
        @setStreamOption 'both'

    setStreamOption: (stdoe) ->
      for option, id in @streams.children()
        if option.attributes.getNamedItem('value').nodeValue is stdoe
          @streams[0].selectedIndex = id
          break
      if stdoe.startsWith 'pty'
        @pty.removeClass 'hidden'

    get: (command) ->
      value = @streams.children()[@streams[0].selectedIndex].attributes.getNamedItem('value').nodeValue
      if value.startsWith 'pty'
        r = 0
        c = 0
        if @pty_cols.getModel().getText() is ''
          c = 80
        else
          c = parseInt(@pty_cols.getModel().getText())
          if Number.isNaN(c)
            return "cols: #{@pty_cols.getModel().getText()} is not a number"
        if @pty_rows.getModel().getText() is ''
          r = 25
        else
          r = parseInt(@pty_rows.getModel().getText())
          if Number.isNaN(r)
            return "rows: #{@pty_rows.getModel().getText()} is not a number"
        command.environment =
          name: 'ptyw'
          config:
            stdoe: value
            rows: r
            cols: c
      else
        command.environment =
          name: 'child_process'
          config:
            stdoe: value
      @_stdout.get command, 'stdout'
      @_stderr.get command, 'stderr'
