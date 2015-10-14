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
            @env.getModel().insertText("#{key}=#{command.modifier.env[key]}\n")
        else
          @env.getModel().setText('')

      get: (command) ->
        command.modifier.env = {}
        for l in @env.getModel().getText().split('\n')
          continue if l.trim() is ''
          key = l.split('=')[0]
          return 'No variable name found' if key.length is 0
          value = l.substr(key.length + 1)
          command.modifier.env[key] = value
        return null

  info:
    class EnvInfoPane
      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        values = document.createElement 'div'

        for key in Object.keys(command.modifier.env)
          _key = document.createElement 'div'
          _key.classList.add 'text-padded'
          _key.innerText = "#{key} = "

          value = document.createElement 'div'
          value.classList.add 'text-padded'
          value.innerText = command.modifier.env[key]

          keys.appendChild _key
          values.appendChild value

        @element.appendChild keys
        @element.appendChild values

  preSplit: (command) ->
    command.env = {}
    for k in Object.keys(command.modifier.env)
      command.env[k] = command.modifier.env[k]
    return
