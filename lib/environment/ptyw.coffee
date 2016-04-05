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
        @process.on 'data', (data) =>
          return unless @process?
          return if @process._emittedClose
          manager.stdout.in(data)
        @process.on 'exit', (exitcode) =>
          return unless exitcode?
          return @resolve(exitcode) if @killed
          @killed = true
          manager.finish exitcode
          @resolve(exitcode)
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
      @killed = true
      @process?.kill()
      @process = null

    sigkill: ->
      @killed = true
      @process?.kill('SIGKILL')
      @process = null

    destroy: ->
      @killed = true
      @promise = null
      @reject = (e) -> console.log "Received reject for finished process: #{e}"
      @resolve = (e) -> console.log "Received resolve for finished process: #{e}"
