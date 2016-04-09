{$, View} = require 'atom-space-pen-views'

module.exports =
  class TabView extends View
    @content: ->
      @div class: 'output'

    printLine: (line) ->
      @append(line)
      @parent().scrollTop(@[0].scrollHeight) unless @hasClass('hidden')
      return @[0].children[@[0].children.length - 1]

    scroll: ->
      @parent().scrollTop(@[0].scrollHeight) unless @hasClass('hidden')

    clear: ->
      @empty()

    finishConsole: (opener) ->
      @find('.filelink').off 'click'
      @find('.filelink').on 'click', ->
        e = $(this)
        lineno = parseInt(e.attr('row'))
        linecol = parseInt(e.attr('col'))
        if e.attr('name') isnt ''
          return opener(e) if opener?
          atom.workspace.open(e.attr('name'),
            initialLine: lineno - 1
            initialColumn: linecol - 1
          )
