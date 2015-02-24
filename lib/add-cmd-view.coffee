{SelectListView, $$} = require 'atom-space-pen-views'

ml = require './message-list.coffee'
btcpp = require './build-tools-cpp.coffee'

module.exports =
class AdditionalCommandsListView extends SelectListView
  possibleFilterKeys: ['name','command']
  dialog: 0 # 0: normal/add; 1: edit; 2: remove

  viewForItem: ({name,command}) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', =>
          @span name
        @div class: 'secondary-line', =>
          @span command

  confirmed: ({name,command}) ->
    if name is "Add"
      @addDialog()
      @cancel()
    else if name is "Edit" then @editDialog()
    else if name is "Remove" then @removeDialog()
    else if @dialog is 2
      ml.removeCommand(name)
      @cancel()
      @dialog = 0
    else if @dialog is 1
      @cancel()
      btcpp.editcommandView.show({name: name,command: command})
    else
      btcpp.execute(command)
      @cancel()

  resetDialog: ->
    @dialog = 0

  getFilterKey: ->
    filter = 'name'
    input = @filterEditorView.getText()
    inputs = input.split(':')
    if inputs.length > 1 and inputs[0] in @possibleFilterKeys
      filter = inputs[0]
    return filter

  getFilterQuery: ->
    input = @filterEditorView.getText()
    inputs = input.split(':')
    if inputs.length > 1 and inputs[0] in @possibleFilterKeys
      return inputs[1]
    return input

  cancel: ->
    super
    @panel.hide()

  show: (items) ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @setItems(items)
    @focusFilterEditor()

  addDialog: ->
    @dialog = 0
    btcpp.editcommandView.show(undefined)
    @cancel()

  editDialog: ->
    @dialog = 1
    s = 3
    if ml.settings.getMake() isnt "" then ++s
    if ml.settings.getConfigure() isnt "" then ++s
    if ml.settings.getPreConfigure() isnt "" then ++s
    items = @items.slice(s)
    @show(items)

  removeDialog: ->
    @dialog = 2
    s = 3
    if ml.settings.getMake() isnt "" then ++s
    if ml.settings.getConfigure() isnt "" then ++s
    if ml.settings.getPreConfigure() isnt "" then ++s
    items = @items.slice(s)
    @show(items)

  dialogConfirm: (item) =>
    if @dialog is 0 then ml.addCommand(item)
    else if @dialog is 1 then ml.editCommand(item)
    @dialog = 0
