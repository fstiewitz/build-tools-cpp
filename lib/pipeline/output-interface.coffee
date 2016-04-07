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

        @stdout.subscribeToCommands output, 'stdout_setType', 'setType'
        @stdout.subscribeToCommands output, 'stdout_replacePrevious', 'replacePrevious'
        @stdout.subscribeToCommands output, 'stdout_print', 'print'
        @stdout.subscribeToCommands output, 'stdout_linter', 'linter'

        @stderr.subscribeToCommands output, 'stderr_setType', 'setType'
        @stderr.subscribeToCommands output, 'stderr_replacePrevious', 'replacePrevious'
        @stderr.subscribeToCommands output, 'stderr_print', 'print'
        @stderr.subscribeToCommands output, 'stderr_linter', 'linter'

    initialize: (command) ->
      for output in @outputs
        output.newCommand?(command)
        output.setInput? @stdin
        @stdin.onWrite output.onInput if output.onInput?

    finish: (status) ->
      @stdout.flush()
      @stderr.flush()
      for output in @outputs
        output.exitCommand?(status)

    error: (error) ->
      for output in @outputs
        output.error?(error)
