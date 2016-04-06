{BufferedProcess} = require 'atom'

module.exports =
  class ChildProcess
    constructor: (@command, manager, @config) ->
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
          if @config.stdoe isnt 'none'
            @process.process.stdout?.setEncoding 'utf8'
            @process.process.stderr?.setEncoding 'utf8'
            setupStream = (stream, into) ->
              stream.on 'data', (data) =>
                return unless @process?
                return if @process.killed
                into.in data
            if @config.stdoe is 'stderr-in-stdout'
              setupStream(@process.process.stdout, manager.stdout)
              setupStream(@process.process.stderr, manager.stdout)
            else if @config.stdoe is 'stdout-in-stderr'
              setupStream(@process.process.stdout, manager.stderr)
              setupStream(@process.process.stderr, manager.stderr)
            else if @config.stdoe is 'no-stdout'
              setupStream(@process.process.stderr, manager.stderr)
            else if @config.stdoe is 'no-stderr'
              setupStream(@process.process.stdout, manager.stdout)
            else if @config.stdoe is 'both'
              setupStream(@process.process.stdout, manager.stdout)
              setupStream(@process.process.stderr, manager.stderr)
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
