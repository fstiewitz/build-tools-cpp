Modifiers = require '../modifier/modifier'
QueueWorker = require './queue-worker'

module.exports =
  class Queue
    constructor: (origin) ->
      if origin.length?
        @queue = queue: origin
      else
        @queue = queue: [origin]
      @keys = Object.keys(@queue.queue[0].modifier ? {}).filter (k) ->
        Modifiers.modules[k]?.in?
      @keys.reverse()

    run: ->
      new Promise((resolve, reject) =>
        @_run(resolve, reject)
      )

    _run: (resolve, reject) ->
      return resolve(new QueueWorker(@queue)) unless (k = @keys.pop())?
      return @_run resolve, reject unless Modifiers.activate(k) is true
      ret = Modifiers.modules[k].in @queue
      if ret instanceof Promise
        ret.catch (e) -> reject(e)
        ret.then => @_run resolve, reject
      else
        reject(new Error(ret)) if ret?
        @_run resolve, reject
