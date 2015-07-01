XRegExp = require('xregexp').XRegExp
ll = require('../linter-list')

module.exports =
  class Profile
    name: ''

    scopes: []

    regex_string: null

    constructor: ->
      extensions_raw = []
      extensions = []
      @scopes.forEach (scope) =>
        if (grammar = atom.grammars.grammarForScopeName(scope))?
          extensions_raw = extensions_raw.concat(grammar.fileTypes)

      extensions_raw = extensions_raw.sort().reverse()

      for extension in extensions_raw
        extensions.push extension.replace(/[.?*+^$[\]\\(){}|-]/g, '\\$&')

      extensions = '(' + extensions.join('|') + ')'
      @regex_string = @regex_string.replace('(?extensions)', extensions)
      @regex = new XRegExp(@regex_string,'xni')
      @file_string = @file_string.replace('(?extensions)', extensions)
      @regex_file = new XRegExp(@file_string,'xni')

    in: (line) ->
      if @regex?
        XRegExp.exec(line, @regex)

    lint: (path, match) ->
      if match? and match.row? and match.type? and match.message?
        if ll.messages[path]?
          ll.messages[path].push match
        else
          ll.messages[path] = [match]

    clear: ->
      return
