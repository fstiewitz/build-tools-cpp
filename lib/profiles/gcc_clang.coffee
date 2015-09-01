module.exports =
  class GCCClang
    @profile_name: 'GCC/Clang'

    scopes: ['source.c++', 'source.cpp', 'source.c', 'source.arduino', 'source.ino']

    default_extensions: ['cc', 'cpp', 'cp', 'cxx', 'c++', 'cu', 'cuh', 'h', 'hh', 'hpp', 'hxx', 'h++', 'inl', 'ipp', 'tcc', 'tpp', 'c', 'h', 'ino', 'pde']

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

    constructor: (@output) ->
      @extensions = @output.createExtensionString @scopes, @default_extensions
      @regex = @output.createRegex @regex_string, @extensions
      @regex_file = @output.createRegex @file_string, @extensions

    files: (line) ->
      start = 0
      out = []
      while (m = @regex_file.xexec line.substr(start))?
        start += m.index
        m.start = start
        m.end = start + m.file.length +
          (if m.row? then m.row.length + 1 else 0) +
          (if m.col? then m.col.length else -1)
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = @regex.xexec line)? #Start of error message
        @status = m.type
        out = []
        m.trace = []
        for line in @prebuffer
          line.type = 'trace'
          line.highlighting = @status
          line.message = m.message
          out.push line #Message to console
          @output.lint line #Trace message to Linter
          line.message = 'Referenced'
          if line? and line.file? and line.row? and line.type? and line.message?
            m.trace.push @output.createMessage line #Message to Traceback
        @output.replacePrevious out
        @prebuffer = []
        @output.print m
        @output.lint m
      else if @regex_end.test line #End of error message
        @output.print input: line, type: @status
        @status = null
      else if @status? #Inside error message
        @output.print input: line, type: @status
      else #Before error message (Traceback)
        if (m = @regex_file.xexec line)?
          @prebuffer.push m
        else
          @prebuffer.push input: line
        @output.print input: line

    clear: ->
      @status = null
      @prebuffer = []
