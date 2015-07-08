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
    (?<message> .*\\s)? #Reference \n
    \\(? #File begin \n
      (?<file> [\\S]+\\.(?extensions)): #File \n
      (?<row> [\\d]+)(:(?<col> [\\d]+))? #Row and column \n
    \\)? #File end \n
    $'

    file_string: '
    (\\(|\")?(?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    '

    constructor: (output) ->
      super(output)
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
      if (m = XRegExp.exec line, @regex_at)? #Traceback
        if @lastMatch?
          if @firstAt and not @lastMatch.file?
            m.type = 'error'
            m.message = @lastMatch.message
            m.trace = []
            @lastMatch = m
          else
            m.type = 'trace'
            m.highlighting = 'error'
            if not m.message? and m.message isnt ' '
              m.message = 'Referenced'
            else if m.message.endsWith ' '
              m.message = m.message.split(0,-1)
            @lastMatch.trace.push @output.createMessage m #Message to Traceback
            @lint m if m.message isnt 'Referenced' #Trace message to Linter
          @output.print m #Message to console
          @firstAt = false
        else
          @output.print m
      else if (m = XRegExp.exec line, @regex_error_nofile)? #Error message
        @lint @lastMatch #Lint last message
        if (n = XRegExp.exec line, @regex_error_file)? #Has file coordinates
          m = n
        m.type = 'error'
        @lastMatch = m
        @firstAt = true
        @output.print m
        @lint m #Lint current message (@lint checks for required fields)
      else
        @firstAt = true
        @lastMatch = null
        @output.print {input: line, type: 'error'}

    clear: ->
      @lastMatch = null
      @firstAt = true
