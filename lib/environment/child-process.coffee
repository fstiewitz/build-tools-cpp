{BufferedProcess} = require 'atom'

module.exports =
  class ChildProcess
    constructor: (@command, manager) ->
      @killed = false
      if atom.inSpecMode()
        @promise = new Promise((@resolve, @reject) =>
          @process =
            exit: (exitcode) =>
              return @resolve(exitcode) if @killed
              @killed = true
              manager.finish exitcode
              @resolve(exitcode)
            error: (error) =>
              manager.error error
              @reject(error)
            kill: =>
              return resolve(null) if @killed
              manager.finish null
              @resolve(null)
        )
      else
        @promise = new Promise((@resolve, @reject) =>
          {command, args, env} = @command
          @process = new BufferedProcess(
            command: command
            args: args
            options:
              cwd: @command.getWD()
              env: env
            stdout: ->
            stderr: ->
            exit: (exitcode) =>
              return @resolve(exitcode) if @killed
              @killed = true
              manager.finish(exitcode)
              @resolve(exitcode)
          )
          @process.process.stdout.setEncoding 'utf8'
          @process.process.stderr.setEncoding 'utf8'
          @process.process.stdout.on 'data', (data) =>
            return unless @process?
            return if @process.killed
            manager.stdout.in(data)
          @process.process.stderr.on 'data', (data) =>
            return unless @process?
            return if @process.killed
            manager.stderr.in(data)
          manager.setInput(@process.process.stdin)
          @process.onWillThrowError ({error, handle}) ->
            manager.error(error)
            handle()
            @reject(error)
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
