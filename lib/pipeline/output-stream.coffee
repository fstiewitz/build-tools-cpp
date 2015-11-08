Profiles = require '../profiles/profiles'

{XRegExp} = require 'xregexp'

fs = require 'fs-plus'
path = require 'path'

{Emitter} = require 'atom'

CSON = require 'season'

ColorRegex = /\x1b\[[0-9;]*m/g
Escape = /\x1b/

module.exports =
  class OutputStream

    constructor: (@settings, @stream) ->
      if @stream.profile?
        @profile = new Profiles.profiles[@stream.profile]?({@setType, @print, @replacePrevious, @createMessage, @absolutePath, @pushLinterMessage, @createExtensionString, @createRegex, @lint})
        if not @profile?
          atom.notifications?.addError "Could not find highlighting profile: #{@stream.profile}"
        @profile?.clear?()
      else
        @profile = null

      if @stream.regex?
        @regex = new XRegExp(@stream.regex, 'xni')
        @default = {}
        @default = CSON.parse(@stream.defaults) if @stream.defaults isnt ''

      @subscribers = new Emitter
      @buffer = ''
      @endsWithAnsi = null

    destroy: ->
      @subscribers.dispose()
      @subscribers = null
      @profile = null
      @regex = null
      @buffer = ''
      @endsWithAnsi = null
      @default = {}

    subscribeToCommands: (object, callback, command) ->
      return unless object?
      return unless object[callback]?
      @subscribers.on command, (o) -> object[callback](o)

    flush: ->
      return if @buffer is ''
      @subscribers.emit 'input', input: @buffer, files: @getFiles(input: @buffer)
      @parse @buffer
      @buffer = ''

    removeAnsi: (data) ->
      data = data.replace(ColorRegex, '')
      if @endsWithAnsi?
        _part = @endsWithAnsi + data
        if ColorRegex.test(_part)
          data = _part.replace(ColorRegex, '')
          @endsWithAnsi = null
        else
          @endsWithAnsi = _part
          data = ''
      if (m = Escape.exec(data))?
        @endsWithAnsi = data.substr(m.index)
        data = data.substr(0, m.index)
      return data

    in: (data) ->
      data = @removeAnsi data if @stream.highlighting isnt 'nh' or @stream.ansi_option is 'remove'
      return if data is ''
      @buffer += data
      lines = @buffer.split '\n'
      for line, index in lines
        if index isnt 0
          @subscribers.emit 'new'
          if line isnt ''
            @subscribers.emit 'raw', line
          if index isnt lines.length - 1
            @subscribers.emit 'input', input: line, files: @getFiles(input: line)
            @parse line
        else
          if line is (d = data.split('\n')[0])
            @subscribers.emit 'new'
          @subscribers.emit 'raw', d
          if lines.length isnt 1
            @subscribers.emit 'input', input: line, files: @getFiles(input: line)
            @parse line
      @buffer = lines.pop()

    parse: (line) ->
      if @stream.highlighting is 'ha'
        @subscribers.emit 'setType', 'warning'
      else if @stream.highlighting is 'ht'
        @subscribers.emit 'setType', v if (v = @parseTags line)?
      else if @stream.highlighting is 'hc' and @profile?
        @profile.in line
      else if @stream.highlighting is 'hr'
        @parseWithRegex line

    parseTags: (line) ->
      /(error|warning):/g.exec(line)?[1]

    parseWithRegex: (line) ->
      return unless @regex?
      if (m = @regex.xexec line)?
        match = {}
        for k in Object.keys(@default)
          match[k] = @default[k]
        for k in Object.keys(m)
          match[k] = m[k] if m[k]?
        @print match
        @lint match

    setType: (match) =>
      @subscribers.emit 'setType', match.highlighting ? match.type

    absolutePath: (relpath) =>
      return fp if fs.existsSync(fp = path.resolve(@settings.project, @settings.wd, relpath))

    createMessage: (match) =>
      row = 1
      col = 10000
      row = parseInt(match.row)
      col = parseInt(match.col) if match.col?
      return {
        type: match.type
        text: match.message
        filePath: @absolutePath match.file
        range: [
          [row - 1, 0]
          [row - 1, if match.col? then col - 1 else 9999]
        ]
      }

    replacePrevious: (new_lines) =>
      items = []
      for line in new_lines
        items.push
          input: line
          files: @getFiles(line)
      @subscribers.emit 'replacePrevious', items

    getFiles: (match) ->
      filenames = []
      if @profile?
        for _match in @profile.files match.input
          _match.file = @absolutePath(_match.file)
          filenames.push _match if fs.isFileSync _match.file
      else if @regex? and match.file?
        start = match.input.indexOf(match.file)
        end = start + match.file.length - 1
        file = @absolutePath(match.file)
        return filenames unless file?
        filenames.push {file: file, start: start, end: end, row: match.row, col: match.col}
      return filenames

    print: (match) =>
      @subscribers.emit 'print', input: match, files: @getFiles(match)

    pushLinterMessage: (message) =>
      @subscribers.emit 'linter', message

    createExtensionString: (scopes, default_extensions) ->
      extensions_raw = []
      extensions = []
      scopes.forEach (scope) ->
        if (grammar = atom.grammars.grammarForScopeName(scope))?
          extensions_raw = extensions_raw.concat(grammar.fileTypes)

      extensions_raw = default_extensions if extensions_raw.length is 0
      extensions_raw = extensions_raw.sort().reverse()

      for extension in extensions_raw
        extensions.push extension.replace(/[.?*+^$[\]\\(){}|-]/g, '\\$&')

      '(' + extensions.join('|') + ')'

    createRegex: (content, extensions) ->
      content = content.replace(/\(\?extensions\)/g, extensions)
      new XRegExp(content, 'xni')

    lint: (match) =>
      if match? and match.file? and match.row? and match.type? and match.message?
        row = 1
        col = 10000
        row = parseInt(match.row)
        col = parseInt(match.col) if match.col?
        @pushLinterMessage
          type: match.type
          text: match.message
          filePath: @absolutePath match.file
          range: [
            [row - 1, 0]
            [row - 1, col - 1]
          ]
          trace: match.trace
