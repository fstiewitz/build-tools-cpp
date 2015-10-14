Modifiers = require '../modifier/modifier'
CommandWorker = require './command-worker'

module.exports =
  class CommandModifier
    constructor: (@command) ->
      @keys = Object.keys(command.modifier ? {})
      @preSplitKeys = @keys.filter (key) ->
        Modifiers.modules[key]?.preSplit?
      @postSplitKeys = @keys.filter (key) ->
        Modifiers.modules[key]?.postSplit?
      @preSplitKeys.reverse()
      @postSplitKeys.reverse()

    run: ->
      new Promise((resolve, reject) =>
        @runPreSplit().then (=>
          @command.getSpawnInfo()
          @runPostSplit().then resolve, reject
        ), reject
      )

    runPreSplit: ->
      new Promise((resolve, reject) =>
        @_runPreSplit resolve, reject
      )

    _runPreSplit: (resolve, reject) ->
      return resolve() unless (k = @preSplitKeys.pop())?
      return @_runPreSplit resolve, reject unless Modifiers.activate(k) is true
      ret = Modifiers.modules[k].preSplit @command
      if ret instanceof Promise
        ret.then (=> @_runPreSplit resolve, reject), reject
      else
        reject(new Error('Error in "' + k + '" module: ' + ret)) if ret?
        @_runPreSplit resolve, reject

    runPostSplit: ->
      new Promise((resolve, reject) =>
        @_runPostSplit resolve, reject
      )

    _runPostSplit: (resolve, reject) ->
      return resolve() unless (k = @postSplitKeys.pop())?
      return @_runPostSplit resolve, reject unless Modifiers.activate(k) is true
      ret = Modifiers.modules[k].postSplit @command
      if ret instanceof Promise
        ret.then (=> @_runPostSplit resolve, reject), reject
      else
        reject(new Error('Error in "' + k + '" module: ' + ret)) if ret?
        @_runPostSplit resolve, reject
