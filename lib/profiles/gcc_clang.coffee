Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class GCCClang extends Profile
    @profile_name: 'GCC/Clang'

    scopes: ['source.c++', 'source.cpp', 'source.c']

    regex_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    :\\s(fatal \\s)? (?<type> error|warning|note): \n
    [\\s]* (?<message> [\\S\\s]+) #Type and Message \n
    '

    regex_end: /^[\^\s~]+$/

    file_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    '

    constructor: (output) ->
      super(output)
      @regex = @createRegex @regex_string
      @regex_file = @createRegex @file_string

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        m.start = start
        m.end = start + m.file.length +
          (if m.row? then m.row.length + 1 else 0) +
          (if m.col? then m.col.length else -1)
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = XRegExp.exec line, @regex)? #Start of error message
        @status = m.type
        out = []
        m.trace = []
        for line in @prebuffer
          line.type = 'trace'
          line.highlighting = @status
          line.message = m.message
          out.push @output.buildHTML line.input, @status #Message to console
          @lint line #Message to Linter
          line.message = 'Referenced'
          if line? and line.file? and line.row? and line.type? and line.message?
            m.trace.push @output.createMessage line #Message to Traceback
        @output.replacePrevious out
        @prebuffer = []
        @output.print m
        @lint m
      else if @regex_end.test line #End of error message
        @output.print input: line, type: @status
        @status = null
      else if @status? #Inside error message
        @output.print input: line, type: @status
      else #Before error message (Traceback)
        if (m = XRegExp.exec line, @regex_file)?
          @prebuffer.push m
        else
          @prebuffer.push input: line
        @output.print input: line

    clear: ->
      @status = null
      @prebuffer = []
