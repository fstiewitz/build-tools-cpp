{$$, SelectListView} = require 'atom-space-pen-views'

module.exports =
  class SelectionView extends SelectListView
    initialize: ->
      super
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @focusFilterEditor()

    viewForItem: (item) ->
      $$ ->
        @li =>
          @div class: 'command-name', item.name
          @div class: 'text-subtle', "#{item.singular} (#{item.origin})"

    confirmed: (item) ->
      @cancel()
      @callback(item)

    cancel: ->
      super
      @panel?.hide()

    getFilterKey: ->
      'name'
