module.exports =
  class Java
    @profile_name: 'Java'

    scopes: ['source.java']

    default_extensions: ['java', 'bsh']

    regex_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    (?<row> [\\d]+)? #Row \n
    :\\s(?<type> error|warning): \n
    [\\s]* (?<message> [\\S\\s]+) #Type and Message \n
    '

    file_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    (?<row> [\\d]+)? #Row\n
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
        m.end = start + m.file.length + (if m.row? then m.row.length else 0)
        m.row = '0' if not m.row?
        m.col = '0'
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = @regex.xexec line)? #Start of error message
        @status = m.type
        @laststatus = @status
        @output.print m
        @output.lint m
      else if /\s+\^\s*/.test(line) #End of error message
        @output.print input: line, type: @status
        @status = null
      else if @status? #Inside error message
        @output.print input: line, type: @status
      else if /required|found|reason|symbol|location/.test(line) #Reason,Found,Required,Symbol and Location fields
        @output.print input: line, type: @laststatus
      else #Rest
        @output.print input: line

    clear: ->
      @status = null
      @laststatus = null
