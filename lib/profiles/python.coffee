Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class Python extends Profile
    @profile_name: 'Python'

    scopes: ['source.python']

    file_string: '
    File\\ "(?<file> [\\S]+\\.(?extensions))", \\ #File \n
    line\\ (?<row> [\\d]+) #Row \n
    '

    message_begin: /^Traceback \(most recent call last\):$/

    trace: /^[\s]+(.+)$/

    constructor: (output) ->
      super(output)
      @regex_file = @createRegex @file_string

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        m.start = start
        m.end = start + m.file.length + m.row.length + 13
        start = m.end + 1
        m.col = '0'
        out.push m
      out

    in: (line) ->
      if (m = XRegExp.exec line, @regex_file)? #File in Traceback
        m.type = 'trace'
        @prebuffer.push m
        @traceback = true
        @output.print input: line, type: 'error'
      else if @traceback and (m = @trace.exec line)? #Message in Traceback
        last = @prebuffer[@prebuffer.length - 1]
        if not last?
          @output.print input: line
          return
        last.message = m[1]  if not last.message? #Append message to last trace location
        @output.print input: line, type: 'error'
      else if (m = XRegExp.exec line, @message_begin)? #Start of traceback?
        @traceback = true
        @output.print input: line, type: 'error'
      else if @traceback and line isnt '' #End of traceback?
        @traceback = false
        last = @prebuffer[@prebuffer.length - 1]
        if not last?
          @output.print input: line
          return
        last.trace = []
        for trace, index in @prebuffer.reverse() #Append traces
          last.trace.push @output.createMessage trace #Message to Traceback
          trace.message = line.trim()
          @lint trace if index isnt 0 #Trace message to Linter
        @prebuffer = []
        last.type = 'error'
        last.message = line.trim()
        @lint last #Message to Linter
        @output.print input: line, type: 'error'
      else
        @output.print input: line

    clear: ->
      @prebuffer = []
      @traceback = false
