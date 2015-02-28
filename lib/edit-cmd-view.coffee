{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class EditCommandView extends View
  nameEditor: null
  commandEditor: null
  @content: ->
    @div class: 'editcommandview', =>
      @div class: 'editor-container', =>
        @subview 'name', new TextEditorView(mini: true, placeholderText: 'Name')
      @div class: 'editor-container', =>
        @subview 'command', new TextEditorView(mini: true, placeholderText: 'Command')

  initialize: (@callback) ->
    @nameEditor = @name.getModel()
    @commandEditor = @command.getModel()
    atom.commands.add @element,
      'core:confirm': (event) =>
        @callback({name: @nameEditor.getText(), command: @commandEditor.getText(), oldname: @oldname})
        event.stopPropagation()
        @cancel()

      'core:cancel': (event) =>
        event.stopPropagation()
        @cancel()

  cancel: ->
    @panel.hide()

  show: (items) ->
    @nameEditor.setText("")
    @commandEditor.setText("")
    @oldname = ""
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    if items?
      @oldname = items.name
      @nameEditor.setText(items.name)
      @commandEditor.setText(items.command)
    @name.focus();
