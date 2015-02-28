{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class SettingsView extends View
  BuildFolderEditor: null
  MakeEditor: null
  ConfigureEditor: null
  PreConfigureEditor: null

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
    @BuildFolderEditor = @BuildFolder.getModel()
    @MakeEditor = @Make.getModel()
    @ConfigureEditor = @Configure.getModel()
    @PreConfigureEditor = @PreConfigure.getModel()
    return

  setBuildFolder: (text) ->
    if text?
      @BuildFolderEditor.setText(text)
    else
      @BuildFolderEditor.setText(".")

  getBuildFolder: ->
    return @BuildFolderEditor.getText()

  setMake:(text) ->
    if text?
      @MakeEditor.setText(text)
    else
      @MakeEditor.setText("make")

  getMake: ->
    return @MakeEditor.getText()

  setConfigure: (text) ->
    @ConfigureEditor.setText(text) if text?

  getConfigure: ->
    return @ConfigureEditor.getText()

  setPreConfigure: (text) ->
    @PreConfigureEditor.setText(text) if text?

  getPreConfigure: ->
    return @PreConfigureEditor.getText()
