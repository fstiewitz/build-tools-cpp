Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class APMTest extends Profile
    @profile_name: 'apm test'

    scopes: ['source.coffee', 'source.js']

    error_string: '^
    [\\s]+ #Indentation \n
    (?<message> .+) #Message \n
    (\\s\\( #EOL or file
      (?<file> [\\S]+\\.(?extensions)): #File \n
      ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    \\))? \n
    $'

    at_string: '^
    [\\s]+ #Indentation \n
    at\\s #At \n
    (.*\\s)? #Reference \n
    \\(? #File begin \n
      (?<file> [\\S]+\\.(?extensions)): #File \n
      ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    \\)? #File end \n
    $'

    file_string: '
    \\(?(?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    '

    constructor: ->
      super
      @regex_error = @createRegex @error_string
      @regex_at = @createRegex @at_string
      @regex_file = @createRegex @file_string

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        start += (if line[start] is '(' then 1 else 0)
        m.start = start
        m.end = start + m.file.length + (if m.row? then m.row.length + 1 else 0) + (if m.col? then m.col.length else -1)
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = XRegExp.exec line, @regex_at)?
        if @lastMatch?
          if @firstAt and not @lastMatch.file?
            m.type = 'error'
          else
            m.type = 'trace'
            m.highlighting = 'error'
          @firstAt = false
          m.message = @lastMatch.message
          return [m]
        else
          return [{input: line, type: 'error'}]
      else if (m = XRegExp.exec line, @regex_error)?
        m.type = 'error'
        @lastMatch = m
        @firstAt = true
        return [m]
      else
        @firstAt = true
        return [{input: line, type: 'error'}]

    clear: ->
      @lastMatch = null
      @firstAt = true
