{View} = require 'atom-space-pen-views'

module.exports =
  class TabItem extends View
    @content: ->
      @li class: 'command-item', =>
        @div class: 'clicker', =>
          @div class: 'icon', outlet: 'icon'
          @div class: 'name', outlet: 'name'
        @div class: 'close icon icon-x'

    initialize: (project, name, close) ->
      @attr('project', project)
      @attr('name', name)
      @find('.close').on 'click', close

    setHeader: (text) ->
      @name.text(text)

    setIcon: (icon) ->
      @icon[0].className = "icon icon-#{icon}"
