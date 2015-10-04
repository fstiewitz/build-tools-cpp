OutputManager = require './output-manager'

{BufferedProcess} = require 'atom'

module.exports =
  class CommandWorker

    constructor: (@command, @outputs) ->
      @manager = new OutputManager(@command, @outputs)

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
        else
          {command, args, env} = @command
          @process = new BufferedProcess(
            command: command
            args: args
            options:
              cwd: @command.getWD()
              env: env
            stdout: (data) =>
              @manager.stdout.in data
            stderr: (data) =>
              @manager.stderr.in data
            exit: (exitcode) =>
              @manager.finish exitcode
              @destroy()
              resolve(exitcode)
          )
          @process.onWillThrowError ({error, handle}) =>
            @manager.error error
            @destroy()
            reject(error)
            handle()
      )

    destroy: ->
      @process?.kill?()
      @manager?.destroy()
      @manager = null
      @process = null
