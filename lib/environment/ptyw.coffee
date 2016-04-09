pty = null

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
