{View} = require 'atom-space-pen-views'

module.exports =
  class SavePane extends View

    @content: ->
      @div class: 'panel-body padded', =>
        @div class: 'block checkbox', outlet: 'save', =>
          @input id: 'save', type: 'checkbox'
          @label =>
            @div class: 'settings-name', 'Save All'
            @div =>
              @span class: 'inline-block text-subtle', 'Save all files before executing your build command'

    set: (command) ->
      if command?
        @find('#save').prop('checked', command.save_all)
      else
        @find('#save').prop('checked', true)

    get: (command) ->
      command.save_all = @find('#save').prop('checked')
      return null
