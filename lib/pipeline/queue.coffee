Modifiers = require '../modifier/modifier'
QueueWorker = require './queue-worker'

module.exports =
  class Queue
    constructor: (origin) ->
      @queue = [origin]
      @keys = Object.keys(origin.modifier?.queue ? {})
      @keys.reverse()

    run: ->
      new Promise((resolve, reject) =>
        @_run(resolve, reject)
      )

    _run: (resolve, reject) ->
      return resolve(new QueueWorker(queue: @queue)) unless (k = @keys.pop())?
      return @_run resolve, reject unless Modifiers.activate(k) is true
      ret = Modifiers.modules[k].in @queue
      if ret instanceof Promise
        ret.catch (e) -> reject(e)
        ret.then => @_run resolve, reject
      else
        reject(ret) if ret?
        @_run resolve, reject
