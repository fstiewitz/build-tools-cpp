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
      mod = Environment.modules[@command.environment.name]
      @environment = new mod(@command, @manager, @command.environment.config)
      return @environment.getPromise()

    kill: ->
      if @environment is null or @environment.isKilled()
        console.log 'Kill on finished process'
        return
      @environment.sigterm() unless @environment.isKilled()

    destroy: ->
      @environment.sigkill() unless @environment.isKilled()
      @manager?.destroy()
      @manager = null
      @environment = null
