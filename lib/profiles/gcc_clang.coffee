Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class GCCClang extends Profile
    name: 'GCC/Clang'

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

    finish: ->
      @prebuffer

    in: (line) ->
      if @regex? and @regex_end?
        if (m = XRegExp.exec line, @regex)?
          if m.type?
            m.type = 'warning' if m.type is 'note'
            @status = m.type
            @continue_status = true
          out = []
          for line in @prebuffer
            line.status = 'trace'
            line.highlighting = @status
            line.message = m.message
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
          return []
      return []

    clear: ->
      @continue_status = false
      @status = null
      @prebuffer = []
