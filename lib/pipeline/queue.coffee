Modifiers = require '../modifier/modifier'
QueueWorker = require './queue-worker'

module.exports =
  class Queue
    constructor: (origin) ->
      @queue = [origin]
      @keys = Object.keys(origin.modifier.queue ? {})

    run: ->
      new Promise((resolve, reject) =>
        for key in @keys
          continue unless Modifiers.activate(key) is true
          mod = Modifiers.modules[key]
          continue unless mod.in?
          reject(e) if(e = mod.in @queue, @queue[0].modifier.queue[key])?
        resolve(new QueueWorker(queue: @queue))
      )
