OutputStream = require './output-stream'
OutputInterface = require './output-interface'
Outputs = require '../output/output'

module.exports =
  class OutputManager

    constructor: (@command, @outputs) ->
      @stdout = new OutputStream(@command.stdout)
      @stderr = new OutputStream(@command.stderr)

      @interface = new OutputInterface(@outputs, @stdout, @stderr)

    destroy: ->
      @stdout.destroy()
      @stderr.destroy()
