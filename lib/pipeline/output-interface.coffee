OutputStream = require './output-stream'

module.exports =
  class OutputInterface

    constructor: (@outputs, @stdout, @stderr) ->
      for output in @outputs
        @stdout.subscribeToInput output.stdout if output.stdout?
        @stderr.subscribeToInput output.stderr if output.stderr?

        if @stdout.highlighting isnt 'nh'
          @stdout.subscribeToCommands output.stdout, 'setType'
          if @stdout.profile?
            @stdout.subscribeToCommands output.stdout, 'replacePrevious'
            @stdout.subscribeToCommands output.stdout, 'print'
            @stdout.subscribeToCommands output.stdout, 'linter'

        if @stderr.highlighting isnt 'nh'
          @stderr.subscribeToCommands output.stderr, 'setType'
          if @stderr.profile?
            @stderr.subscribeToCommands output.stderr, 'replacePrevious'
            @stderr.subscribeToCommands output.stderr, 'print'
            @stderr.subscribeToCommands output.stderr, 'linter'

    initialize: (command) ->
      for output in @outputs
        output.newCommand?(command)

    finish: (exitcode) ->
      for output in @outputs
        output.exitCommand?(exitcode)

    error: (error) ->
      for output in @outputs
        output.error error
