{View, TextEditorView} = require 'atom-space-pen-views'

fs = null
path = null

module.exports =

  name: 'Log File'
  description: 'Write command output to log file'
  private: false

  activate: ->
    fs = require 'fs'
    path = require 'path'

  deactivate: ->
    fs = null
    path = null

  edit:
    class LogPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'File Path'
              @div =>
                @span class: 'inline-block text-subtle', 'File path (absolute or relative)'
            @subview 'command_name', new TextEditorView(mini: true, placeholderText: 'Default: output.log')

      set: (command) ->
        if command?
          command.output.file ?= {}
          @command_name.getModel().setText(command.output.file.path ? '')
        else
          @command_name.getModel().setText('')

      get: (command) ->
        out = 'output.log' if (out = @command_name.getModel().getText()) is ''
        command.output.file.path = out
        return null

  info:
    class LogInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class: 'text-padded'>Log Path</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.file.path)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Log
      newQueue: (@queue) ->
        @stdout.__this = this
        @stderr.__this = this

      newCommand: (command) ->
        _path = path.resolve(command.project, command.output.file.path)
        @fd = null
        @fd = fs.createWriteStream _path

      stdout:
        in: ({input}) ->
          @__this.fd.write input + '\n'

      stderr:
        in: ({input}) ->
          @__this.fd.write input + '\n'

      exitCommand: ->
        @.fd.end()
