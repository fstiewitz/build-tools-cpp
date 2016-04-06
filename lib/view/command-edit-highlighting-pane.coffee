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

    get: (command) ->
      value = @streams.children()[@streams[0].selectedIndex].attributes.getNamedItem('value').nodeValue
      if value.startsWith 'pty'
        command.environment =
          name: 'ptyw'
          config:
            into: value.substr(4)
      else
        command.environment =
          name: 'child_process'
          config:
            stdio: value
      @_stdout.get command, 'stdout'
      @_stderr.get command, 'stderr'
