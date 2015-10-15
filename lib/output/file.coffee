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
            @subview 'file_path', new TextEditorView(mini: true, placeholderText: 'Default: output.log')
          @div class: 'block checkbox', =>
            @input id: 'all_in_one', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Log output to one file per queue'
              @div =>
                @span class: 'inline-block text-subtle', 'Print output of all commands of the queue to this file'

      set: (command) ->
        if command?.output?.file?
          @file_path.getModel().setText(command.output.file.path ? '')
          @find('#all_in_one').prop('checked', command.output.file.queue_in_file ? true)
        else
          @file_path.getModel().setText('')
          @find('#all_in_one').prop('checked', true)

      get: (command) ->
        out = 'output.log' if (out = @file_path.getModel().getText()) is ''
        command.output.file ?= {}
        command.output.file.path = out
        command.output.file.queue_in_file = @find('#all_in_one').prop('checked')
        return null

  info:
    class LogInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class="text-padded">Log path:</div>
        <div class="text-padded">Write queue to file:</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.file.path)
        values.appendChild value
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.file.queue_in_file)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Log
      newQueue: (queue) ->
        @fd = null
        @shared_fd = false
        if (c = queue.queue[queue.queue.length - 1]).output.file?.queue_in_file
          @shared_fd = true
          _path = path.resolve(c.project, c.output.file.path)
          @fd = null
          @fd = fs.createWriteStream _path

      newCommand: (command) ->
        return if @shared_fd
        _path = path.resolve(command.project, command.output.file.path)
        @fd = null
        @fd = fs.createWriteStream _path

      stdout_in: ({input}) ->
        @fd.write input + '\n'

      stderr_in: ({input}) ->
        @fd.write input + '\n'

      exitCommand: ->
        @fd.end() unless @shared_fd

      exitQueue: ->
        @fd.end() if @shared_fd
