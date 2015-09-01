module.exports =
  class APMTest
    @profile_name: 'apm test'

    scopes: ['source.coffee', 'source.js']

    default_extensions: ['js', 'htc', '_js', 'es', 'es6', 'jsm', 'pjs', 'xsjs', 'xsjslib', 'coffee', 'Cakefile', 'coffee.erb', 'cson', '_coffee']

    error_string_file: '^ \n
    [\\s]+ #Indentation \n
    (?<message> .+) #Message \n
    \\.?\\s\\( #File \n
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

    constructor: (@output) ->
      @extensions = @output.createExtensionString @scopes, @default_extensions
      @regex_at = @output.createRegex @at_string, @extensions
      @regex_error_file = @output.createRegex @error_string_file, @extensions
      @regex_error_nofile = @output.createRegex @error_string_nofile, @extensions
      @regex_file = @output.createRegex @file_string, @extensions

    files: (line) ->
      start = 0
      out = []
      while (m = @regex_file.xexec line.substr(start))?
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
      if (m = @regex_at.xexec line)? #Traceback
        if @lastMatch?
          if @firstAt and not @lastMatch.file?
            m.type = 'error'
            m.message = @lastMatch.message
            m.trace = []
            @lastMatch = m
          else
            m.type = 'trace'
            m.highlighting = 'error'
            if not m.message? or m.message.trim() isnt ''
              m.message = 'Referenced'
            @lastMatch.trace.push @output.createMessage m #Message to Traceback
            m.message = @lastMatch.message
            @output.lint m #Trace message to Linter
          @output.print m #Message to console
          @firstAt = false
        else
          @output.print m
      else if (m = @regex_error_nofile.xexec line)? #Error message
        @output.lint @lastMatch #Lint last message
        if (n = @regex_error_file.xexec line, @regex_error_file)? #Has file coordinates
          m = n
        m.type = 'error'
        @lastMatch = m
        @firstAt = true
        @output.print m
        @output.lint m #Lint current message (@lint checks for required fields)
      else
        @output.lint @lastMatch #Lint last message
        @firstAt = true
        @lastMatch = null
        @output.print {input: line, type: 'error'}

    clear: ->
      @lastMatch = null
      @firstAt = true
