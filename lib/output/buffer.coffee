{View} = require 'atom-space-pen-views'

buffers = {}

module.exports =

  name: 'Text Buffer'
  description: 'Display command output in unnamed text buffer'
  private: false

  activate: ->
    buffers = {}

  deactivate: ->
    buffers = {}

  edit:
    class BufferPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block checkbox', =>
            @input id: 'recycle_buffer', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Recycle editor tab'
              @div =>
                @span class: 'inline-block text-subtle', 'Re-use the same buffer'

      set: (command) ->
        if command?
          command.output.buffer ?= {}
          @find('#recycle_buffer').prop('checked', command.output.buffer.recycle_buffer)
        else
          @find('#recycle_buffer').prop('checked', true)

      get: (command) ->
        command.output.buffer.recycle_buffer = @find('#recycle_buffer').prop('checked')
        return null

  info:
    class BufferInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class: 'text-padded'>Recycle Buffer</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.buffer.recycle_buffer)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Buffer
      newQueue: (@queue) ->
        @stdout.__this = this
        @stderr.__this = this

      newCommand: (command) ->
        if command.output.buffer.recycle_buffer
          buffers[command.project] ?= {}
          if (@buffer = buffers[command.project][command.name])?
            @buffer.setText('')
          else
            (@p = atom.workspace.open(null)).then (@buffer) =>
              buffers[command.project][command.name] = @buffer
              @buffer.onDidDestroy =>
                @buffer = null
                buffers[command.project][command.name] = null
              @p = null
        else
          (@p = atom.workspace.open(null)).then (@buffer) =>
            @p = null
            @buffer.onDidDestroy =>
              @buffer = null

      stdout:
        in: ({input}) ->
          if @__this.p?
            @__this.p.then (buffer) =>
              @__this.buffer = buffer
              @__this.p = null
              @__this.buffer?.insertText input + '\n'
          else
            @__this.buffer?.insertText input + '\n'

      stderr:
        in: ({input}) ->
          if @__this.p?
            @__this.p.then (buffer) =>
              @__this.buffer = buffer
              @__this.p = null
              @__this.buffer?.insertText input + '\n'
          else
            @__this.buffer?.insertText input + '\n'
