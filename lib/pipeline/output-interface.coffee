OutputStream = require './output-stream'

module.exports =
  class OutputInterface

    constructor: (@outputs, @stdin, @stdout, @stderr) ->
      for output in @outputs
        @stdout.subscribeToCommands output, 'stdout_new', 'new'
        @stdout.subscribeToCommands output, 'stdout_raw', 'raw'
        @stdout.subscribeToCommands output, 'stdout_in', 'input'

        @stderr.subscribeToCommands output, 'stderr_new', 'new'
        @stderr.subscribeToCommands output, 'stderr_raw', 'raw'
        @stderr.subscribeToCommands output, 'stderr_in', 'input'

        output.setInput? @stdin.write
        @stdin.onWrite output.onInput if output.onInput?

        if @stdout.highlighting isnt 'nh'
          @stdout.subscribeToCommands output, 'stdout_setType', 'setType'
          if @stdout.profile? or @stdout.regex?
            @stdout.subscribeToCommands output, 'stdout_replacePrevious', 'replacePrevious'
            @stdout.subscribeToCommands output, 'stdout_print', 'print'
            @stdout.subscribeToCommands output, 'stdout_linter', 'linter'

        if @stderr.highlighting isnt 'nh'
          @stderr.subscribeToCommands output, 'stderr_setType', 'setType'
          if @stderr.profile? or @stderr.regex?
            @stderr.subscribeToCommands output, 'stderr_replacePrevious', 'replacePrevious'
            @stderr.subscribeToCommands output, 'stderr_print', 'print'
            @stderr.subscribeToCommands output, 'stderr_linter', 'linter'

    initialize: (command) ->
      for output in @outputs
        output.newCommand?(command)

    finish: (exitcode) ->
      @stdout.flush()
      @stderr.flush()
      for output in @outputs
        output.exitCommand?(exitcode)

    error: (error) ->
      for output in @outputs
        output.error?(error)
