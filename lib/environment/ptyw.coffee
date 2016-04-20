pty = null

{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
  name: 'Spawn in Pseudo-Terminal'

  info:
    class PtyInfoPane
      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        values = document.createElement 'div'

        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Rows:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = command.environment.config.rows
        keys.appendChild key
        values.appendChild value

        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Columns:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = command.environment.config.cols
        keys.appendChild key
        values.appendChild value

        @element.appendChild keys
        @element.appendChild values

  edit:
    class PtyEditPane extends View

      @content: ->
        @content: ->
          @div class: 'panel-body', =>
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'Output Streams'
                @div =>
                  @span class: 'inline-block text-subtle', 'Configure standard output/error stream'
              @select class: 'form-control', outlet: 'streams', =>
                @option value: 'pty-stdout', 'Use pty.js + redirect stderr in stdout'
                @option value: 'pty-stderr', 'Use pty.js + redirect stdout in stderr'

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

        set: (command, sourceFile) ->
          if command?
            for option, id in @streams.children()
              if option.attributes.getNamedItem('value').nodeValue is stdoe
                @streams[0].selectedIndex = id
                break
            @pty_rows.getModel().setText(command.environment.config.rows)
            @pty_cols.getModel().setText(command.environment.config.cols)
          else
            @streams[0].selectedIndex = 0
            @pty_rows.getModel().setText('')
            @pty_cols.getModel().setText('')


        get: (command) ->
          value = @streams.children()[@streams[0].selectedIndex].attributes.getNamedItem('value').nodeValue

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

  mod:
    class Ptyw
      constructor: (@command, manager, @config) ->
        {command, args, env} = @command
        pty = require 'ptyw.js'
        @promise = new Promise((@resolve, @reject) =>
          @process = pty.spawn(command, args, {
            name: 'xterm-color'
            cols: @config.cols
            rows: @config.rows
            cwd: @command.getWD()
            env: env
          }
          )
          if @config.stdoe is 'pty-stdout'
            @process.on 'data', (data) =>
              return unless @process?
              return if @killed
              data = data.replace /\r/g, ''
              manager.stdout.in(data)
          else
            @process.on 'data', (data) =>
              return unless @process?
              return if @killed
              data = data.replace /\r/g, ''
              manager.stderr.in(data)
          @process.on 'exit', (exitcode, signal) =>
            return unless exitcode? and signal?
            if signal isnt 0
              exitcode = null
              signal = 128 + signal
            else if exitcode >= 128
              signal = exitcode
              exitcode = null
            else
              signal = null
            @killed = true
            manager.finish({exitcode, signal})
            @resolve({exitcode, signal})
          manager.setInput(@process)
        )
        @promise.then(
          =>
            @destroy()
          =>
            @destroy()
        )

      getPromise: ->
        @promise

      isKilled: ->
        @killed

      sigterm: ->
        @process?.write '\x03', 'utf8'

      sigkill: ->
        @process?.kill('SIGKILL')

      destroy: ->
        @killed = true
        @promise = null
        @process = null
        @reject = (e) -> console.log "Received reject for finished process: #{e}"
        @resolve = (e) -> console.log "Received resolve for finished process: #{e}"
