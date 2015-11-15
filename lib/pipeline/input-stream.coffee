{Emitter} = require 'atom'

module.exports =
  class InputStream
    constructor: ->
      @input = null
      @writers = new Emitter

    setInput: (@input) ->
      @writers.emit 'attach', @input

    destroy: ->
      @input?.end?()
      @writers.dispose()
      @input = null
      @writers = null

    onWrite: (callback) ->
      @writers.on 'write', callback

    onAttach: (callback) ->
      @writers.on 'attach', callback

    write: (text) =>
      @input.write text, 'utf8', => @writers.emit 'write', text
