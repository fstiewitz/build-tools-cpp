module.exports =
  class Modelsim
    @profile_name: 'Modelsim'

    scopes: ['source.vhdl' , 'source.verilog']

    default_extensions: ['vhd', 'vhdl', 'vho', 'v', 'sv', 'vh']

    regex_string: '
    (?<type> Error|Warning):[ ](?<file> [\\S]+\\.(?extensions))\\((?<row> [\\d]+)\\):[ ](?<message> .+)$
    '

    file_string: '
    (?<file> [\\S]+\\.(?extensions))(\\((?<row> [\\d]+)\\))?
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
        m.end = start + m.file.length + (if m.row? then m.row.length + 1 else -1)
        m.row = '0' if not m.row?
        m.col = '0'
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = @regex.xexec line)? #Start of error message
        m.type = m.type.toLowerCase()
        @output.print m
        @output.lint m
