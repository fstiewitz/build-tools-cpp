Command = null
{View} = require 'atom-space-pen-views'

module.exports =

  name: 'Execute in Shell'
  description: 'Execute command in a shell'
  private: false

  view:
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
        if command?
          command.modifier.shell ?= {}
          @command_name.getModel().setText(command.modifier.shell.command ? '')
        else
          @command_name.getModel().setText('')

      get: (command) ->
        out = 'bash -c' if (out = @command_name.getModel().getText()) is ''
        command.modifier.shell.command = out
        return null

  activate: ->
    Command = require '../provider/command'

  deactivate: ->
    Command = null

  postSplit: (command) ->
    args = Command.splitQuotes command.modifier.shell.command
    command.args = args.slice(1).concat([command.original])
    command.command = args[0]
    return
