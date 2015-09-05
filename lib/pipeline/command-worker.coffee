OutputManager = require './output-manager'

{BufferedProcess} = require 'atom'

module.exports =
  class CommandWorker

    constructor: (@command, @outputs, @finish, @error) ->
      @manager = new OutputManager(@command, @outputs)

      {cmd, args, wd, env} = @command.getSpawnInfo()
      if atom.inSpecMode()
        @process =
          exit: (exitcode) =>
            @manager.finish exitcode
            @destroy()
            @finish(exitcode)
          error: (error) =>
            @manager.error error
            @destroy()
            @error(error)
      else
        @process = new BufferedProcess(
          command: cmd
          args: args
          options:
            cwd: wd
            env: env
          stdout: (data) =>
            @manager.stdout.in data
          stderr: (data) =>
            @manager.stderr.in data
          exit: (exitcode) =>
            @manager.finish exitcode
            @destroy()
            @finish(exitcode)
        )
        @process.onWillThrowError ({error, handle}) =>
          @manager.error error
          @destroy()
          @error(error)
          handle()

    destroy: ->
      @process?.kill?()
      @manager?.destroy()
      @manager = null
      @process = null
