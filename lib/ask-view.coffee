{View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class AskView extends View
    @content: ->
      @div class:'ask-view', =>
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Command'
          @subview 'command', new TextEditorView(mini: true)
          @div id:'command-none', class:'error hidden', 'Command cannot be empty'
        @div class:'buttons', =>
          @div class: 'btn btn-error icon icon-x inline-block-tight', 'Cancel'
          @div class: 'btn btn-primary icon icon-check inline-block-tight', 'Accept'
    initialize: ->
      @Command = @command.getModel()

      @on 'click', '.buttons .icon-x', @cancel
      @on 'click', '.buttons .icon-check', @accept

      @disposables = new CompositeDisposable
      @disposables.add atom.commands.add @element,
        'core:confirm': @accept
        'core:cancel': @cancel

    destroy: ->
      @disposables.dispose()
      @detach()

    accept: (event) =>
      @find('.error').addClass('hidden')
      if (c = @Command.getText()) isnt ''
        @callback c
        @hide()
      else
        @find('.error').removeClass('hidden')
      event.stopPropagation()

    cancel: (event) =>
      @hide()
      event.stopPropagation()

    hide: ->
      @panel?.hide()

    show: (command, @callback) ->
      @Command.setText command
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @command.focus()
