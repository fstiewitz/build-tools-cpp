pty = null

module.exports =
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
            return if @process._emittedClose
            manager.stdout.in(data)
        else
          @process.on 'data', (data) =>
            return unless @process?
            return if @process._emittedClose
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
