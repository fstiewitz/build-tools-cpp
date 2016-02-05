XRegExp = null
CSON = null

module.exports =

  activate: ->
    XRegExp = require('xregexp').XRegExp
    CSON = require('season')

  deactivate: ->
    XRegExp = null
    CSON = null

  modifier:
    class RegexModifier

      constructor: (@config, @command, @output) ->
        @regex = new XRegExp(@config.regex, 'xni')
        @default = {}
        @default = CSON.parse(@config.defaults) if @config.defaults? and @config.defaults isnt ''

      modify: ({temp, perm}) ->
        if (m = @regex.xexec temp.input)?
          match = {}
          for k in Object.keys(@default)
            match[k] = @default[k]
          for k in Object.keys(m)
            match[k] = m[k] if m[k]?
          for k in Object.keys(match)
            temp[k] = perm[k] = match[k]
        return null

      getFiles: ({temp, perm}) ->
        return [] unless temp.file?
        start = temp.input.indexOf(temp.file)
        end = start + temp.file.length - 1
        file = @output.absolutePath(temp.file)
        return [] unless file?
        return [{file: file, start: start, end: end, row: temp.row, col: temp.col}]
