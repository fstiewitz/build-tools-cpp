OutputStream = require './output-stream'
OutputInterface = require './output-interface'
Outputs = require '../output/output'

module.exports =
  class OutputManager

    constructor: (@command, @outputs) ->
      @stdout = new OutputStream(@command, @command.stdout)
      @stderr = new OutputStream(@command, @command.stderr)

      @interface = new OutputInterface(@outputs, @stdout, @stderr)
      @interface.initialize(@command)

    destroy: ->
      @stdout.destroy()
      @stderr.destroy()

    finish: (exitcode) ->
      @interface.finish(exitcode)

    error: (error) ->
      @interface.error error
