{View} = require 'atom-space-pen-views'

module.exports =
  class TabView extends View
    @content: ->
      @div class: 'output'

    initialize: ->
      @lockoutput = false

    printLine: (line) ->
      return null if @lockoutput
      @append(line)
      @scrollTop(@[0].scrollHeight)
      return @[0].children[@[0].children.length - 1]

    lock: ->
      @lockoutput = true

    unlock: ->
      @lockoutput = false

    clear: ->
      @text('')

    finishConsole: ->
      @find('.filelink').on 'click', ->
        e = $(this)
        lineno = parseInt(e.attr('row'))
        linecol = parseInt(e.attr('col'))
        if e.attr('name') isnt ''
          atom.workspace.open(e.attr('name'),
            initialLine: lineno - 1
            initialColumn: linecol - 1
          )
