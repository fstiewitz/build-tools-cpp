Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class GCCClang extends Profile
    @profile_name: 'GCC/Clang'

    scopes: ['source.c++', 'source.cpp', 'source.c']

    regex_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    :\\s(fatal \\s)? (?<type> error|warning|note): [\\s]* (?<message> [\\S\\s]+) #Type and Message \n
    '

    regex_end: /^[\^\s~]+$/

    file_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    '

    constructor: ->
      super

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        m.start = start
        m.end = start + m.file.length + (if m.row? then m.row.length + 1 else 0) + (if m.col? then m.col.length else -1)
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if @regex? and @regex_end?
        if (m = XRegExp.exec line, @regex)?
          if m.type?
            m.type = 'warning' if m.type is 'note'
            @status = m.type
            @continue_status = true
          out = []
          for line in @prebuffer
            line.type = 'trace'
            line.highlighting = @status
            line.message = m.message
            line.wait = false
            out.push line
          @prebuffer = []
          out.push m
          return out
        else if @regex_end.test(line)
          @continue_status = false
          return [{input: line, type: @status}]
        else if @continue_status
          return [{input: line, type: @status}]
        else
          if (m = XRegExp.exec line, @regex_file)?
            m.type = 'trace'
            @prebuffer.push m
          else
            @prebuffer.push {input: line}
          return [{input: line, wait: true}]
      return [{input: line}]

    clear: ->
      @continue_status = false
      @status = null
      @prebuffer = []
