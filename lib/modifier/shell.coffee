Command = null
{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =

  name: 'Execute in Shell'
  description: 'Execute command in a shell'
  private: false

  edit:
    class ShellPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Shell Command'
              @div =>
                @span class: 'inline-block text-subtle', 'Your command will be appended to the shell command'
            @subview 'command_name', new TextEditorView(mini: true, placeholderText: 'Default: bash -c')

      set: (command) ->
        if command?.modifier?.shell?
          @command_name.getModel().setText(command.modifier.shell.command)
        else
          @command_name.getModel().setText('')

      get: (command) ->
        out = 'bash -c' if (out = @command_name.getModel().getText()) is ''
        command.modifier.shell ?= {}
        command.modifier.shell.command = out
        return null

  info:
    class ShellInfoPane
      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class="text-padded">Shell Command:</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.modifier.shell.command)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  activate: ->
    Command = require '../provider/command'

  deactivate: ->
    Command = null

  postSplit: (command) ->
    args = Command.splitQuotes command.modifier.shell.command
    command.args = args.slice(1).concat([command.original])
    command.command = args[0]
    return
