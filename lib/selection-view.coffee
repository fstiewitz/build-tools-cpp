{SelectListView, $$} = require 'atom-space-pen-views'

module.exports =
class CommandSelection extends SelectListView
  viewForItem: ({name, command}) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', =>
          @span name
        @div class: 'secondary-line', =>
          @span command

  confirmed: ({name}) ->
    @cancel()
    @cb(name)

  cancel: ->
    super
    @panel?.hide()

  show: (@project, @cb) ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @setItems(@project.commands)
    @focusFilterEditor()

  getFilterKey: ->
    'name'
