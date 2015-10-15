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
        @currentWorker.run().then ((exitcode) =>
          @finishedCommand(exitcode)
          if exitcode is 0
            @_run resolve, reject
          else
            resolve(exitcode)
        ), (e) =>
          @errorCommand e
          resolve(-1)
      ), reject

    stop: ->
      return if @finished
      return @finished = true unless @currentWorker?
      @currentWorker.destroy()
      @finishedQueue -2

    finishedQueue: (code) ->
      @finished = true
      for key in Object.keys(@outputs)
        @outputs[key].exitQueue?(code)
      @emitter.emit 'finishedQueue', code
      @destroy()

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
