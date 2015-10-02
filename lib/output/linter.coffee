ll = require '../linter-list'

{View} = require 'atom-space-pen-views'

coordinates = {}

module.exports =

  name: 'Linter'
  description: 'Highlight errors in-line with Linter'
  private: false

  edit:
    class LinterSaver extends View
      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block checkbox', =>
            @input id: 'no_trace', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Disable Trace'
              @div =>
                @span class: 'inline-block text-subtle', 'Do not send stack traces to Linter'

      set: (command) ->
        if command?.output.linter?
          @find('#no_trace').prop('checked', command.output.linter.no_trace)
        else
          @find('#no_trace').prop('checked', false)

      get: (command) ->
        command.output.linter ?= {}
        command.output.linter.no_trace = @find('#no_trace').prop('checked')
        return null

  info:
    class LinterInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class: 'text-padded'>Disable stack traces:</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.linter.no_trace)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Linter

      newQueue: (@queue) ->
        ll.messages = []
        coordinates = {}
        @stdout._this = @stderr._this = this

      newCommand: (@command) ->

      stdout:
        linter: (message) ->
          return ll.messages.push message if atom.inSpecMode()
          return if coordinates[message.filePath + ':' + message.range[0][0]]?
          coordinates[message.filePath + ':' + message.range[0][0]] = true
          if @_this.command.output.linter.no_trace
            message.trace = null
          ll.messages.push message

      stderr:
        linter: (message) ->
          return ll.messages.push message if atom.inSpecMode()
          return if coordinates[message.filePath + ':' + message.range[0][0]]?
          coordinates[message.filePath + ':' + message.range[0][0]] = true
          if @_this.command.output.linter.no_trace
            message.trace = null
          ll.messages.push message

      exitQueue: (code) ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'linter:lint')
