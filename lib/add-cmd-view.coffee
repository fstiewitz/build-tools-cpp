{SelectListView, $$} = require 'atom-space-pen-views'

module.exports =
class AdditionalCommandsListView extends SelectListView

  viewForItem: (item) ->
    $$ -> @li(item)

  confirmed: (item) ->
    @cancel()

  cancel: ->
    super
    @panel.hide()

  show: (items) ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @setItems(items)
    @focusFilterEditor()
