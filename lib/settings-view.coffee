{$$$,View,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class SettingsView extends View
    @content: ->
        @div class: 'settings', =>
            @div class: 'block', =>
                @div class: 'editor', =>
                    @subview 'BuildFolderView', new TextEditorView(mini: true, placeholderText: 'Build folder')
            @div class: 'block', =>
                @div class: 'editor', =>
                    @subview 'Make', new TextEditorView(mini:true, placeholderText: 'Make command')
            @div class: 'block', =>
                @div class: 'editor', =>
                    @subview 'Configure', new TextEditorView(mini: true, placeholderText: 'Configure command')
            @div class: 'block', =>
                @div class: 'editor', =>
                    @subview 'PreConfigure', new TextEditorView(mini: true, placeholderText: 'Pre configure command')

    initialize: ->
        return
