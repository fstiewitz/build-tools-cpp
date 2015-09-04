OutputStream = require './output-stream'

module.exports =
  class OutputInterface

    constructor: (@outputs, @stdout, @stderr) ->
      for output in @outputs
        @stdout.subscribeToInput output.stdout if output.stdout?
        @stderr.subscribeToInput output.stderr if output.stderr?

        if @stdout.profile?
          @stdout.subscribeToCommands output.stdout, 'setType'
          @stdout.subscribeToCommands output.stdout, 'replacePrevious'
          @stdout.subscribeToCommands output.stdout, 'print'
          @stdout.subscribeToCommands output.stdout, 'linter'

        if @stderr.profile?
          @stderr.subscribeToCommands output.stderr, 'setType'
          @stderr.subscribeToCommands output.stderr, 'replacePrevious'
          @stderr.subscribeToCommands output.stderr, 'print'
          @stderr.subscribeToCommands output.stderr, 'linter'
