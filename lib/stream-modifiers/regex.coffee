XRegExp = null
CSON = null
{$, $$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =

  name: 'Regular Expression'

  activate: ->
    XRegExp = require('xregexp').XRegExp
    CSON = require('season')

  deactivate: ->
    XRegExp = null
    CSON = null

  info:
    class RegexInfoPane
      constructor: (command, config) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        values = document.createElement 'div'

        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Regular Expression:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = config.regex
        keys.appendChild key
        values.appendChild value

        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Default Values:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = config.defaults
        keys.appendChild key
        values.appendChild value

        @element.appendChild keys
        @element.appendChild values

  edit:
    class RegexEditPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Regular Expression'
              @div =>
                @span class: 'inline-block text-subtle', 'Enter XRegExp string. The XRegExp object will use '
                @span class: 'inline-block highlight', 'xni'
                @span class: 'inline-block text-subtle', ' flags. Refer to the internet (including this package\'s wiki) for details.'
            @subview 'regex', new TextEditorView(mini: true)
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Hardcoded values'
              @div =>
                @span class: 'inline-block text-subtle', 'Enter CSON string with default properties. To highlight an error you need at least a '
                @span class: 'inline-block highlight', 'type'
                @span class: 'inline-block text-subtle', ' field. Linter messages require at least '
                @span class: 'inline-block highlight', 'type'
                @span class: 'inline-block text-subtle', ', '
                @span class: 'inline-block highlight', 'file'
                @span class: 'inline-block text-subtle', ', '
                @span class: 'inline-block highlight', 'row'
                @span class: 'inline-block text-subtle', ' and '
                @span class: 'inline-block highlight', 'message'
                @span class: 'inline-block text-subtle', ' fields.'
            @subview 'default', new TextEditorView(mini: true)

      set: (command, config) ->
        if command?
          @regex.getModel().setText(config.regex)
          @default.getModel().setText(config.defaults)
        else
          @regex.getModel().setText('')
          @default.getModel().setText('')

      get: (command, stream) ->
        return 'Regular expression must not be empty' if @regex.getModel().getText() is ''
        command[stream].pipeline.push {
          name: 'regex'
          config:
            regex: @regex.getModel().getText()
            defaults: @default.getModel().getText()
        }
        return null


  modifier:
    class RegexModifier

      constructor: (@config, @command, @output) ->
        @regex = new XRegExp(@config.regex, 'xni')
        @default = {}
        @default = CSON.parse(@config.defaults) if @config.defaults? and @config.defaults isnt ''

      modify: ({temp, perm}) ->
        if (m = @regex.xexec temp.input)?
          match = {}
          for k in Object.keys(@default)
            match[k] = @default[k]
          for k in Object.keys(m)
            match[k] = m[k] if m[k]?
          for k in Object.keys(match)
            temp[k] = perm[k] = match[k]
        return null

      getFiles: ({temp, perm}) ->
        return [] unless temp.file?
        start = temp.input.indexOf(temp.file)
        end = start + temp.file.length - 1
        file = @output.absolutePath(temp.file)
        return [] unless file?
        return [{file: file, start: start, end: end, row: temp.row, col: temp.col}]
