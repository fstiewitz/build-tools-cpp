CommandWorker = require './command-worker'
Outputs = require '../output/output'
{Emitter} = require 'atom'

module.exports =
  class QueueWorker

    constructor: (@queue, @outputs) ->
      if not @outputs?
        @outputs = {}

        for command in @queue
          for key in Object.keys(command.output)
            @outputs[key] = new Outputs.modules[key].output if Outputs.modules[key]? and not @outputs[key]

      for key in Object.keys(@outputs)
        @outputs[key].newQueue @queue

      @emitter = new Emitter
      @finished = false

    destroy: ->
      @finished = true
      @emitter.dispose()
      @currentWorker.destroy() if not @finished
      @outputs = null

    run: ->
      return if @finished
      command = @queue.splice(0, 1)[0]
      return @finishedQueue 0 unless command?
      outputs = []
      for key in Object.keys(command.output)
        outputs.push @outputs[key]
      @currentWorker = new CommandWorker(command, outputs, @finishedCommand, @errorCommand)

    stop: ->
      @currentWorker.destroy()
      @finishedQueue -2

    finishedQueue: (code) ->
      @emitter.emit 'finishedQueue', code
      for key in Object.keys(@outputs)
        @outputs[key].exitQueue(code)
      @finished = true

    hasFinished: ->
      @finished

    finishedCommand: (exitcode) =>
      @emitter.emit 'finishedCommand', exitcode
      if exitcode is 0
        @run()
      else
        @finishedQueue exitcode

    errorCommand: (error) =>
      @emitter.emit 'errorCommand', error
      @finishedQueue -1
