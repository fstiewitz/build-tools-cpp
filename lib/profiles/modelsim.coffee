Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class Modelsim extends Profile
    @profile_name: 'Modelsim'

    scopes: ['source.vhdl' , 'source.verilog']

    default_extensions: ['vhd']

    regex_string: '
    (?<type> Error|Warning):[ ](?<file> [\\S]+\\.(?extensions))\\((?<row> [\\d]+)\\):[ ](?<message> .+)$
    '

    file_string: '
    (?<file> [\\S]+\\.(?extensions))(\\((?<row> [\\d]+)\\))?
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
        m.end = start + m.file.length + (if m.row? then m.row.length + 1 else -1)
        m.row = '0' if not m.row?
        m.col = '0'
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = XRegExp.exec line, @regex)? #Start of error message
        m.type = m.type.toLowerCase()
        @output.print m
        @lint m
