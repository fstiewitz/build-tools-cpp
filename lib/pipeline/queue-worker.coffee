CommandWorker = require './command-worker'
CommandModifier = require './command-modifier'
Outputs = require '../output/output'
{Emitter} = require 'atom'

module.exports =
  class QueueWorker

    constructor: (@queue) ->
      @outputs = {}

      for command in @queue.queue
        for key in Object.keys(command.output)
          continue unless Outputs.activate(key) is true
          @outputs[key] = new Outputs.modules[key].output if not @outputs[key]

      for key in Object.keys(@outputs)
        @outputs[key].newQueue?(@queue)

      @emitter = new Emitter
      @finished = false

    destroy: ->
      @emitter.dispose()
      @queue = null
      @outputs = null

    run: ->
      new Promise((resolve, reject) =>
        @_run resolve, reject
      )

    _run: (resolve, reject) ->
      throw new Error('Worker already finished') if @finished
      unless (c = @queue.queue.splice(0, 1)[0])?
        @finishedQueue 0
        return resolve(0)
      modifier = new CommandModifier(c)
      modifier.run().then (=>
        outputs = (@outputs[key] for key in Object.keys(c.output) when @outputs[key]?)
        @currentWorker = new CommandWorker(c, outputs)
        @currentWorker.run().then ((status) =>
          @finishedCommand(status)
          if status.exitcode is 0
            @_run resolve, reject
          else
            resolve(status)
        ), (e) =>
          @errorCommand e
          resolve(exitcode: -1, status: null)
      ), reject

    stop: ->
      return if @finished
      return @finished = true unless @currentWorker?
      @currentWorker.kill().then => @finishedQueue -2

    finishedQueue: (code) ->
      @finished = true
      for key in Object.keys(@outputs)
        @outputs[key].exitQueue?(code)
      @emitter.emit 'finishedQueue', code
      @destroy()

    hasFinished: ->
      @finished

    finishedCommand: (status) ->
      @currentWorker.destroy()
      @emitter.emit 'finishedCommand', status
      if status.exitcode isnt null and status.exitcode isnt 0
        return if status.exitcode >= 128
        @finishedQueue status.exitcode

    errorCommand: (error) ->
      @emitter.emit 'errorCommand', error
      @finishedQueue -1

    onFinishedQueue: (callback) ->
      @emitter.on 'finishedQueue', callback

    onFinishedCommand: (callback) ->
      @emitter.on 'finishedCommand', callback

    onError: (callback) ->
      @emitter.on 'errorCommand', callback
