module.exports =
  class Python
    @profile_name: 'Python'

    scopes: ['source.python']

    default_extensions: ['cpy', 'gyp', 'gypi', 'kv', 'py', 'pyw', 'rpy', 'SConscript', 'SConstruct', 'Sconstruct', 'sconstruct', 'Snakefile', 'tac', 'wsgi']

    file_string: '
    File\\ "(?<file> [\\S]+\\.(?extensions))", \\ #File \n
    line\\ (?<row> [\\d]+) #Row \n
    '

    message_begin: /^Traceback \(most recent call last\):$/

    trace: /^[\s]+(.+)$/

    constructor: (@output) ->
      @extensions = @output.createExtensionString @scopes, @default_extensions
      @regex_file = @output.createRegex @file_string, @extensions

    files: (line) ->
      start = 0
      out = []
      while (m = @regex_file.xexec line.substr(start))?
        start += m.index
        m.start = start
        m.end = start + m.file.length + m.row.length + 13
        start = m.end + 1
        m.col = '0'
        out.push m
      out

    in: (line) ->
      if (m = @regex_file.xexec line)? #File in Traceback
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
      else if (m = @message_begin.exec line)? #Start of traceback?
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
          @output.lint trace if index isnt 0 #Trace message to Linter
        @prebuffer = []
        last.type = 'error'
        last.message = line.trim()
        @output.lint last #Message to Linter
        @output.print input: line, type: 'error'
      else
        @output.print input: line

    clear: ->
      @prebuffer = []
      @traceback = false
