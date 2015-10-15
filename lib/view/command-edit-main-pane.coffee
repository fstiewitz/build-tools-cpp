{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
  class MainPane extends View

    @content: ->
      @div class: 'panel-body padded', =>
        @div class: 'block', =>
          @label =>
            @div class: 'settings-name', 'Command Name'
            @div =>
              @span class: 'inline-block text-subtle', 'Name of command when using '
              @span class: 'inline-block highlight', 'build-tools:commands'
          @subview 'command_name', new TextEditorView(mini: true)
          @div id: 'name-error-none', class: 'error hidden', 'This field cannot be empty'
          @div id: 'name-error-used', class: 'error hidden', 'Name already used in this project'
        @div class: 'block', =>
          @label =>
            @div class: 'settings-header', =>
              @div class: 'settings-name', 'Command'
              @div class: 'wildcard-info icon-info', =>
                @div class: 'content', =>
                  @div class: 'text-highlight bold', 'Wildcards'
                  @div class: 'info', =>
                    @div class: 'col', =>
                      @div 'Current File'
                      @div 'Base Path'
                      @div 'Folder (rel.)'
                      @div 'File (no ext.)'
                    @div class: 'col', =>
                      @div class: 'text-highlight', '%f'
                      @div class: 'text-highlight', '%b'
                      @div class: 'text-highlight', '%d'
                      @div class: 'text-highlight', '%e'
            @div =>
              @span class: 'inline-block text-subtle', 'Command to execute '
          @subview 'command_text', new TextEditorView(mini: true)
          @div id: 'command-error-none', class: 'error hidden', 'This field cannot be empty'
        @div class: 'block', =>
          @label =>
            @div class: 'settings-header', =>
              @div class: 'settings-name', 'Working Directory'
              @div class: 'wildcard-info icon-info', =>
                @div class: 'content', =>
                  @div class: 'text-highlight bold', 'Wildcards'
                  @div class: 'info', =>
                    @div class: 'col', =>
                      @div 'Current File'
                      @div 'Base Path'
                      @div 'Folder (rel.)'
                      @div 'File (no ext.)'
                    @div class: 'col', =>
                      @div class: 'text-highlight', '%f'
                      @div class: 'text-highlight', '%b'
                      @div class: 'text-highlight', '%d'
                      @div class: 'text-highlight', '%e'
            @div =>
              @span class: 'inline-block text-subtle', 'Directory to execute command in'
          @subview 'working_directory', new TextEditorView(mini: true, placeholderText: '.')

    set: (command) ->
      if command?
        @command_name.getModel().setText(command.name)
        @command_text.getModel().setText(command.command)
        @working_directory.getModel().setText(command.wd)
      else
        @command_name.getModel().setText('')
        @command_text.getModel().setText('')
        @working_directory.getModel().setText('.')

    get: (command) ->
      return 'Empty Name' if (n = @command_name.getModel().getText()) is ''
      return 'Empty Command' if (c = @command_text.getModel().getText()) is ''
      w.setText '.' if (w = @working_directory.getModel()).getText() is ''
      command.name = n
      command.command = c
      command.wd = w.getText()
      return null
