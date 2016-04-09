InputStream = require './input-stream'
OutputStream = require './output-stream'
OutputInterface = require './output-interface'
Outputs = require '../output/output'

module.exports =
  class OutputManager

    constructor: (@command, @outputs) ->
      @stdin = new InputStream
      @stdout = new OutputStream(@command, @command.stdout)
      @stderr = new OutputStream(@command, @command.stderr)

      @stdin.onWrite (text) =>
        @stdout.in text unless @stdin.isPTY()

      @interface = new OutputInterface(@outputs, @stdin, @stdout, @stderr)
      @interface.initialize(@command)

    setInput: (input) ->
      @stdin.setInput input

    destroy: ->
      @stdin.destroy()
      @stdout.destroy()
      @stderr.destroy()

    finish: (status) ->
      @interface.finish(status)

    error: (error) ->
      @interface.error error
