{BufferedProcess} = require 'atom'

pstree = null

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
              @killed = true
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
          )
          @process.process.on 'exit', (exitcode, signal) =>
            console.log "#{exitcode},#{signal}"
            @killed = true
            manager.finish(exitcode)
            @resolve(exitcode)
          if @config.stdoe isnt 'none'
            @process.process.stdout?.setEncoding 'utf8'
            @process.process.stderr?.setEncoding 'utf8'
            setupStream = (stream, into) ->
              stream.on 'data', (data) =>
                return unless @process?
                return if @killed
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
      @sendSignal 'SIGINT'

    sigkill: ->
      @sendSignal 'SIGKILL'

    sendSignal: (signal) ->
      if process.platform is 'win32'
        @process?.kill(signal)
      else
        (pstree ? pstree = require 'ps-tree') @process.process.pid, (e, c) =>
          return if e?
          for child in c
            try
              process.kill child.PID, signal
            catch e
              console.log e
          try
            @process.process.kill signal
            @process.killed = true
          catch e
            console.log e

    destroy: ->
      @killed = true
      @promise = null
      @process = null
      @reject = (e) -> console.log "Received reject for finished process: #{e}"
      @resolve = (e) -> console.log "Received resolve for finished process: #{e}"
