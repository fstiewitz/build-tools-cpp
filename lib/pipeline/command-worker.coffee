InputOutputManager = require './io-manager'

{BufferedProcess} = require 'atom'

module.exports =
  class CommandWorker

    constructor: (@command, @outputs) ->
      @manager = new InputOutputManager(@command, @outputs)
      @killed = false

    run: ->
      new Promise((resolve, reject) =>
        if atom.inSpecMode()
          @process =
            exit: (exitcode) =>
              return resolve(exitcode) if @killed
              @killed = true
              @manager.finish exitcode
              @destroy()
              resolve(exitcode)
            error: (error) =>
              @manager.error error
              @destroy()
              reject(error)
            kill: =>
              return resolve(null) if @killed
              @manager.finish null
              @destroy()
              resolve(null)
          @manager.setInput
            write: ->
            end: ->
        else
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
              return resolve(exitcode) if @killed
              @killed = true
              @manager.finish exitcode
              @destroy()
              resolve(exitcode)
          )
          @process.process.stdout.setEncoding 'utf8'
          @process.process.stderr.setEncoding 'utf8'
          @process.process.stdout.on 'data', (data) =>
            return unless @process?
            return if @process.killed
            @manager.stdout.in(data)
          @process.process.stderr.on 'data', (data) =>
            return unless @process?
            return if @process.killed
            @manager.stderr.in(data)
          @manager.setInput(@process.process.stdin)
          @process.onWillThrowError ({error, handle}) =>
            @manager.error error
            @destroy()
            handle()
            reject(error)
      )

    kill: ->
      @killed = true
      @process?.kill?()
      @process = null

    destroy: ->
      @kill() unless @killed
      @manager?.destroy()
      @manager = null
