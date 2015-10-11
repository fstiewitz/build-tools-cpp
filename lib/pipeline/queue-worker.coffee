CommandWorker = require './command-worker'
CommandModifier = require './command-modifier'
Outputs = require '../output/output'
{Emitter} = require 'atom'

module.exports =
  class QueueWorker

    constructor: (@queue, @outputs) ->
      if not @outputs?
        @outputs = {}

        for command in @queue.queue
          for key in Object.keys(command.output)
            continue unless Outputs.activate(key) is true
            @outputs[key] = new Outputs.modules[key].output if Outputs.modules[key]? and not @outputs[key]

      for key in Object.keys(@outputs)
        @outputs[key].newQueue?(@queue)

      @emitter = new Emitter
      @finished = false

    destroy: ->
      @currentWorker.destroy() if not @finished
      @finished = true
      @emitter.dispose()
      @outputs = null

    run: ->
      new Promise((resolve, reject) =>
        @_run resolve, reject
      )

    _run: (resolve, reject) ->
      return reject('Worker already finished') if @finished
      unless (c = @queue.queue.splice(0, 1)[0])?
        @finishedQueue 0
        return resolve()
      modifier = new CommandModifier(c)
      mods = modifier.run()
      mods.catch (e) -> reject(e)
      mods.then =>
        outputs = (@outputs[key] for key in Object.keys(c.output) when @outputs[key]?)
        @currentWorker = new CommandWorker(c, outputs)
        ret = @currentWorker.run()
        ret.catch (e) =>
          @errorCommand e
          reject(e)
        ret.then (exitcode) =>
          @finishedCommand(exitcode)
          if exitcode is 0
            @_run resolve, reject
          else
            reject("Command finished with exit code #{exitcode}")

    stop: ->
      return if @finished
      @currentWorker.destroy()
      @finishedQueue -2

    finishedQueue: (code) ->
      @emitter.emit 'finishedQueue', code
      for key in Object.keys(@outputs)
        @outputs[key].exitQueue?(code)
      @finished = true

    hasFinished: ->
      @finished

    finishedCommand: (exitcode) ->
      @emitter.emit 'finishedCommand', exitcode
      if exitcode isnt 0
        @finishedQueue exitcode

    errorCommand: (error) ->
      @emitter.emit 'errorCommand', error
      @finishedQueue -1

    onFinishedQueue: (callback) ->
      @emitter.on 'finishedQueue', callback

    onFinishedCommand: (callback) ->
      @emitter.on 'finishedCommand', callback

    onError: (callback) ->
      @emitter.on 'errorCommand', callback
