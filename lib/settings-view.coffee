{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class SettingsView extends View
  @content: ->
    @div class: 'settings', =>
      @div class: 'editor-container', =>
        @subview 'BuildFolder', new TextEditorView(mini: true, placeholderText: 'Build folder')
      @div class: 'editor-container', =>
        @subview 'Make', new TextEditorView(mini:true, placeholderText: 'Make command')
      @div class: 'editor-container', =>
        @subview 'Configure', new TextEditorView(mini: true, placeholderText: 'Configure command')
      @div class: 'editor-container', =>
        @subview 'PreConfigure', new TextEditorView(mini: true, placeholderText: 'Pre configure command')

  initialize: ->
    return

  setBuildFolder: (text) ->
    if text?
      @BuildFolder.setText(text)
    else
      @BuildFolder.setText(".")

  getBuildFolder: ->
    return @BuildFolder.getText()

  setMake:(text) ->
    if text?
      @Make.setText(text)
    else
      @Make.setText("make")

  getMake: ->
    return @Make.getText()

  setConfigure: (text) ->
    @Configure.setText(text) if text?

  getConfigure: ->
    return @Configure.getText()

  setPreConfigure: (text) ->
    @PreConfigure.setText(text) if text?

  getPreConfigure: ->
    return @PreConfigure.getText()
