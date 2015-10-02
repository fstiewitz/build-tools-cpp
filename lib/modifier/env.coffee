{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =

  name: 'Environment Variables'
  description: 'Add/Change environment variables. Each line has the format "VARIABLE=VALUE". One variable per line'
  private: false

  edit:
    class EnvPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @subview 'env', new TextEditorView()

      set: (command) ->
        if command?.modifier.env?
          for key in Object.keys(command.modifier.env ? {})
            @env.getModel().insertText("#{key}=#{command.env[key]}\n")
        else
          @env.getModel().setText('')

      get: (command) ->
        command.modifier.env = {}
        for l in @env.getModel().getText().split('\n')
          key = l.split('=')[0]
          value = l.substr(key.length + 1)
          command.modifier.env[key] = value
        return null

  preSplit: (command) ->
    command.env = {}
    for k in Object.keys(command.modifier.env)
      command.env[k] = command.modifier.env[k]
    return
