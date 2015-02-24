{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class EditCommandView extends View
  @content: ->
    @div class: 'editcommandview', =>
      @div class: 'editor-container', =>
        @subview 'name', new TextEditorView(mini: true, placeholderText: 'Name')
      @div class: 'editor-container', =>
        @subview 'command', new TextEditorView(mini: true, placeholderText: 'Command')

  initialize: (@callback) ->
    atom.commands.add @element,
      'core:confirm': (event) =>
        @callback({name: @name.getText(), command: @command.getText(), oldname: @oldname})
        event.stopPropagation()
        @cancel()

      'core:cancel': (event) =>
        event.stopPropagation()
        @cancel()

  cancel: ->
    @panel.hide()

  show: (items) ->
    @name.setText("")
    @command.setText("")
    @oldname = ""
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    if items?
      @oldname = items.name
      @name.setText(items.name)
      @command.setText(items.command)
    @name.focus();
