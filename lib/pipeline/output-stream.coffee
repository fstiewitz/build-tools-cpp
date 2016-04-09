{Emitter} = require 'atom'

Pipeline = require './output-pipeline'
RawPipeline = require './output-pipeline-raw'

module.exports =
  class OutputStream

    constructor: (@settings, @stream) ->
      @subscribers = new Emitter
      @buffer = ''
      @flushed = false
      @wholepipeline = new Pipeline(@settings, @stream)
      @rawpipeline = new RawPipeline(@settings, @stream)

    destroy: ->
      @subscribers.dispose()
      @subscribers = null
      @wholepipeline.destroy()
      @rawpipeline.destroy()
      @wholepipeline = null
      @rawpipeline = null
      @buffer = ''

    subscribeToCommands: (object, callback, command) ->
      return unless object?
      return unless object[callback]?
      if command in ['new', 'raw', 'input']
        @subscribers.on command, (o) -> object[callback](o)
      else
        @wholepipeline.subscribeToCommands object, callback, command

    flush: ->
      @flushed = true
      return if @buffer is ''
      @subscribers.emit 'input', input: @buffer, files: @wholepipeline.getFiles(input: @buffer)
      @wholepipeline.in @rawpipeline.in(@buffer)
      @buffer = ''

    in: (data) ->
      return if @flushed
      data = @rawpipeline.in data
      return if data is ''
      @buffer += data
      lines = @buffer.split '\n'
      for line, index in lines
        break if line is '' and index is lines.length - 1
        if index isnt 0
          @subscribers.emit 'new'
          if line isnt ''
            @subscribers.emit 'raw', line
          if index isnt lines.length - 1
            @subscribers.emit 'input', input: line, files: @wholepipeline.getFiles(input: line)
            @wholepipeline.in line
        else
          if line is (d = data.split('\n')[0])
            @subscribers.emit 'new'
          @subscribers.emit 'raw', d
          if lines.length isnt 1
            @subscribers.emit 'input', input: line, files: @wholepipeline.getFiles(input: line)
            @wholepipeline.in line
      @buffer = lines.pop()
