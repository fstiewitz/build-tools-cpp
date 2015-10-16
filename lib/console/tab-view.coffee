{$, View} = require 'atom-space-pen-views'

module.exports =
  class TabView extends View
    @content: ->
      @div class: 'output'

    initialize: ->
      @lockoutput = false

    printLine: (line) ->
      return null if @lockoutput
      @append(line)
      @parent().scrollTop(@[0].scrollHeight) unless @hasClass('hidden')
      return @[0].children[@[0].children.length - 1]

    lock: ->
      @lockoutput = true

    unlock: ->
      @lockoutput = false

    clear: ->
      @empty()

    finishConsole: ->
      @find('.filelink').off 'click'
      @find('.filelink').on 'click', ->
        e = $(this)
        lineno = parseInt(e.attr('row'))
        linecol = parseInt(e.attr('col'))
        if e.attr('name') isnt ''
          atom.workspace.open(e.attr('name'),
            initialLine: lineno - 1
            initialColumn: linecol - 1
          )
