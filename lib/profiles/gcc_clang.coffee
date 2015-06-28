Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class GCCClang extends Profile
    name: 'GCC/Clang'

    scopes: ['source.c++', 'source.cpp', 'source.c']

    regex_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    ((?<row> [\\d]+)(:(?<col> [\\d]+))?)? #Row and column \n
    (:[\\w\\s]* (?<type> error|warning|note): [\\s]* (?<message> [\\S\\s]+))? #Type and Message \n
    '

    regex_end: /^[\^\s~]+$/

    in: (line) ->
      if @regex? and @regex_end?
        if (m = XRegExp.exec line, @regex)?
          if m.type?
            m.type = 'warning' if m.type is 'note'
            @status = m.type
            if m.message?
              if @continue_status
                m.type = 'trace'
              else
                @continue_status = true
          return m
        else if @regex_end.test(line)
          @continue_status = false
          return type: @status
        else if @continue_status
          return type: @status

    clear: ->
      @continue_status = false
      @status = null
