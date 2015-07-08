XRegExp = require('xregexp').XRegExp
ll = require('../linter-list')

module.exports =
  class Profile
    name: ''

    scopes: []

    regex_string: null

    constructor: (@output)->
      extensions_raw = []
      @extensions = []
      @scopes.forEach (scope) ->
        if (grammar = atom.grammars.grammarForScopeName(scope))?
          extensions_raw = extensions_raw.concat(grammar.fileTypes)

      extensions_raw = extensions_raw.sort().reverse()

      for extension in extensions_raw
        @extensions.push extension.replace(/[.?*+^$[\]\\(){}|-]/g, '\\$&')

      @extensions = '(' + @extensions.join('|') + ')'

    createRegex: (content) ->
      content = content.replace(/\(\?extensions\)/g, @extensions)
      new XRegExp(content, 'xni')

    in: (line) ->
      if @regex?
        XRegExp.exec(line, @regex)

    lint: (match) ->
      if match? and match.file? and match.row? and match.type? and match.message?
        row = 1
        col = 10000
        row = parseInt(match.row)
        col = parseInt(match.col) if match.col?
        ll.messages.push
          type: match.type
          text: match.message
          filePath: @output.absolutePath match.file
          range: [
            [row-1,0]
            [row-1,if match.col? then col-1 else 9999]
          ]
          trace: match.trace

    clear: ->
      return
