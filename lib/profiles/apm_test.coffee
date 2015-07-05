Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class APMTest extends Profile
    @profile_name: 'apm test'

    scopes: ['source.coffee', 'source.js']

    error_string_file: '^ \n
    [\\s]+ #Indentation \n
    (?<message> .+) #Message \n
    \\.\\s\\( #File \n
      (?<file> [\\S]+\\.(?extensions)): #File \n
      ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    \\) \n
    $'

    error_string_nofile: '^ \n
    [\\s]+ #Indentation \n
    (?<message> .+) #Message \n
    $'

    at_string: '^ \n
    [\\s]+ #Indentation \n
    at\\s #At \n
    (.*\\s)? #Reference \n
    \\(? #File begin \n
      (?<file> [\\S]+\\.(?extensions)): #File \n
      ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    \\)? #File end \n
    $'

    file_string: '
    (\\(|\")?(?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    '

    constructor: ->
      super
      @regex_at = @createRegex @at_string
      @regex_error_file = @createRegex @error_string_file
      @regex_error_nofile = @createRegex @error_string_nofile
      @regex_file = @createRegex @file_string

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        start += (if line[start] is '(' or line[start] is '"' then 1 else 0)
        m.start = start
        m.end = start + m.file.length +
          (if m.row? then m.row.length + 1 else 0) +
          (if m.col? then m.col.length else -1)
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
      else if (m = XRegExp.exec line, @regex_error_nofile)?
        if (n = XRegExp.exec line, @regex_error_file)?
          m = n
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
