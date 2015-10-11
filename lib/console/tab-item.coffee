{View} = require 'atom-space-pen-views'

module.exports =
  class TabItem extends View
    @content: ->
      @li class: 'command-item', =>
        @div class: 'name icon', outlet: 'name'
        @div class: 'close icon icon-x'

    initialize: (project, name, close) ->
      @attr('project', project)
      @attr('name', name)
      @find('.close').on 'click', close

    setHeader: (text) ->
      @name.text(text)

    setSpinner: ->
      @name[0].className = 'name loading loading-spinner-tiny'

    setIcon: (icon) ->
      @name[0].className = "name icon icon-#{icon}"
