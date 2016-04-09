path = require 'path'
Queue = require '../pipeline/queue'

module.exports =
  class Command
    constructor: ({@project, @source, @name, @command, @wd, @env, @modifier, @environment, @stdout, @stderr, @output, @version} = {}) ->
      @env ?= {}
      @wd ?= '.'
      @modifier ?= {}
      @output ?= {}
      @stdout ?= highlighting: 'nh'
      @stderr ?= highlighting: 'nh'
      @version ?= 1
      @migrateToV2() if @version is 1

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

    migrateToV2: ->
      if @stdout.pty is true
        @environment =
          name: 'ptyw'
          config:
            rows: @stdout.pty_rows
            cols: @stdout.pty_cols
        delete @stdout.pty
        delete @stdout.pty_rows
        delete @stdout.pty_cols
      else
        @environment =
          name: 'child_process'
          config:
            stdoe: 'both'
      @migrateStreamV2 @stdout
      @migrateStreamV2 @stderr
      @version = 2

    migrateStreamV2: (str) ->
      return if str.pipeline?
      str.pipeline = []
      if str.highlighting is 'nh'
        if str.ansi_option is 'remove'
          str.pipeline.push name: 'remansi'
      else if str.highlighting is 'ha'
        str.pipeline.push name: 'all'
      else if str.highlighting is 'hc'
        str.pipeline.push name: 'profile', config: {profile: str.profile}
      else if str.highlighting is 'hr'
        str.pipeline.push {
          name: 'regex'
          config:
            regex: str.regex
            defaults: str.defaults
        }
      else if str.highlighting is 'ht'
        str.pipeline.push {
          name: 'regex'
          config:
            regex: '(?<type> error|warning):'
        }
      delete str.highlighting
      delete str.profile
      delete str.ansi_option
      delete str.regex
      delete str.defaults

    getQueue: ->
      new Queue(this)
