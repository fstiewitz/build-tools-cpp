InputOutputManager = require './io-manager'

{BufferedProcess} = require 'atom'

module.exports =
  class CommandWorker

    constructor: (@command, @outputs) ->
      @manager = new InputOutputManager(@command, @outputs)

    run: ->
      new Promise((resolve, reject) =>
        if atom.inSpecMode()
          @process =
            exit: (exitcode) =>
              @manager.finish exitcode
              @destroy()
              resolve(exitcode)
            error: (error) =>
              @manager.error error
              @destroy()
              reject(error)
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
            exit: (exitcode) =>
              @manager.finish exitcode
              @destroy()
              resolve(exitcode)
          )
          @process.process.stdout.setEncoding 'utf8'
          @process.process.stderr.setEncoding 'utf8'
          @process.process.stdout.on 'data', @manager.stdout.in
          @process.process.stderr.on 'data', @manager.stderr.in
          @manager.setInput(@process.process.stdin)
          @process.onWillThrowError ({error, handle}) =>
            @manager.error error
            @destroy()
            handle()
            reject(error)
      )

    destroy: ->
      @process?.kill?()
      @manager?.destroy()
      @manager = null
      @process = null
