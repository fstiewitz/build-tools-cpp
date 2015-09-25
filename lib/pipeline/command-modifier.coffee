Modifiers = require '../modifier/modifier'
CommandWorker = require './command-worker'

module.exports =
  class CommandModifier
    constructor: (@command) ->
      @keys = Object.keys(command.modifier?.command ? {})
      @preSplitKeys = @keys.filter (key) ->
        Modifiers.modules[key]?.preSplit?
      @postSplitKeys = @keys.filter (key) ->
        Modifiers.modules[key]?.postSplit?
      @preSplitKeys.reverse()
      @postSplitKeys.reverse()

    run: ->
      new Promise((resolve, reject) =>
        rs = @runPreSplit()
        rs.catch (e) -> reject(e)
        rs.then =>
          @command.getSpawnInfo()
          os = @runPostSplit()
          os.catch (e) -> reject(e)
          os.then -> resolve()
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
        ret.catch (e) -> reject(e)
        ret.then => @_runPreSplit resolve, reject
      else
        reject(ret) if ret?
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
        ret.catch (e) -> reject(e)
        ret.then => @_runPostSplit resolve, reject
      else
        reject(ret) if ret?
        @_runPostSplit resolve, reject
