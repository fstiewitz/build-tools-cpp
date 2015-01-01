{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class SettingsView extends View
    @content: ->
        @div class: 'settings', =>
            @div class: 'editor-container', =>
                @subview 'BuildFolderView', new TextEditorView(mini: true, placeholderText: 'Build folder')
            @div class: 'editor-container', =>
                @subview 'Make', new TextEditorView(mini:true, placeholderText: 'Make command')
            @div class: 'editor-container', =>
                @subview 'Configure', new TextEditorView(mini: true, placeholderText: 'Configure command')
            @div class: 'editor-container', =>
                @subview 'PreConfigure', new TextEditorView(mini: true, placeholderText: 'Pre configure command')

    initialize: ->
        return
