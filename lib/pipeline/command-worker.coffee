InputOutputManager = require './io-manager'

Environment = require '../environment/environment'

pty = null

module.exports =
  class CommandWorker

    constructor: (@command, @outputs) ->
      @manager = new InputOutputManager(@command, @outputs)
      @killed = false

    run: ->
      unless Environment.activate(@command.environment?.name)
        @manager.error "Could not find environment module #{@command.environment?.name}"
        return Promise.reject("Could not find environment module #{@command.environment?.name}")
      mod = Environment.modules[@command.environment.name].mod
      @environment = new mod(@command, @manager, @command.environment.config)
      return @environment.getPromise()

    kill: ->
      if @environment is null or @environment.isKilled()
        console.log 'Kill on finished process'
        return Promise.resolve()
      new Promise((resolve) =>
        @environment.getPromise().then resolve, resolve
        @environment.sigterm() unless @environment.isKilled()
        setTimeout(
          =>
            return unless @environment?
            @environment.sigkill() unless @environment.isKilled()
        , 3000)
      )

    destroy: ->
      @environment.sigkill() unless @environment.isKilled() or atom.inSpecMode()
      @environment.destroy()
      @manager?.destroy()
      @manager = null
      @environment = null
