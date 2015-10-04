path = require 'path'
Queue = require '../pipeline/queue'

module.exports =
  class Command
    constructor: ({@project, @name, @command, @wd, @env, @modifier, @stdout, @stderr, @output, @version} = {}) ->
      @env ?= {}
      @wd ?= '.'
      @modifier ?= {}
      @output ?= {}
      @stdout ?= highlighting: 'nh'
      @stderr ?= highlighting: 'nh'
      @version ?= 1

    getSpawnInfo: ->
      @original = @command
      args = Command.splitQuotes @command
      @command = args[0]
      @args = args.slice(1)
      @mergeEnvironment process.env

    getWD: ->
      path.resolve(@project, @wd)

    mergeEnvironment: (env) ->
      @env[key] = env[key] for key in Object.keys(env) when not @env[key]

    @splitQuotes: (cmd_string) ->
      args = []
      cmd_list = cmd_string.split(' ')
      instring = false
      getQuoteIndex = (line) ->
        return {index: c, character: '"'} if (c = line.indexOf('"')) isnt -1
        return {index: c, character: "'"} if (c = line.indexOf("'")) isnt -1
      while (cmd_list.length isnt 0)
        if not instring
          args.push cmd_list[0]
        else
          args[args.length - 1] += ' ' + cmd_list[0]
        qi = getQuoteIndex(cmd_list[0])
        if (qi = getQuoteIndex(cmd_list[0]))?
          if instring
            instring = false
          else
            if cmd_list[0].substr(qi.index + 1).indexOf(qi.character) is -1
              instring = true
        cmd_list.shift()
      (args[i] = a.slice(1, -1) for a, i in args when /[\"\']/.test(a[0]) and /[\"\']/.test(a[a.length - 1]))
      return args

    getQueue: ->
      new Queue(this)
