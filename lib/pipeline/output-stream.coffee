Profiles = require '../profiles/profiles'

{XRegExp} = require 'xregexp'

fs = require 'fs-plus'
path = require 'path'

{Emitter} = require 'atom'

module.exports =
  class OutputStream

    constructor: (@settings, @stream) ->
      if @stream.profile?
        @profile = new Profiles.profiles[@stream.profile]?({@print, @replacePrevious, @createMessage, @absolutePath, @pushLinterMessage, @createExtensionString, @createRegex, @lint})
        if not @profile?
          atom.notifications?.addError "Could not find highlighting profile: #{@stream.profile}"
        @profile?.clear?()
      else
        @profile = null

      @subscribers = new Emitter

    destroy: ->
      @subscribers.dispose()
      @subscribers = null
      @profile = null

    subscribeToCommands: (subscriber, command) ->
      return unless subscriber?
      return unless subscriber[command]?
      @subscribers.on command, (o) -> subscriber[command](o)

    subscribeToInput: (subscriber) ->
      return unless subscriber?
      return unless subscriber.in?
      @subscribers.on 'input', (o) -> subscriber.in(o)

    in: (message) ->
      lines = message.split('\n')
      for line, index in lines
        if line isnt '' or (line is '' and index isnt lines.length - 1)
          @subscribers.emit 'input', input: line, files: @getFiles(line)
          @parse line

    parse: (line) ->
      if @stream.highlighting is 'ha'
        @subscribers.emit 'setType', 'warning'
      else if @stream.highlighting is 'ht'
        @subscribers.emit 'setType', v if (v = @parseTags line)?
      else if @stream.highlighting is 'hc' and @profile?
        @profile.in line


    parseTags: (line) ->
      /(error|warning):/g.exec(line)?[1]

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
          files: @getFiles(line.input)
      @subscribers.emit 'replacePrevious', items

    getFiles: (line) ->
      if @profile?
        filenames = []
        for match in @profile.files line
          match.file = @absolutePath(match.file)
          filenames.push match if fs.isFileSync match.file
        return filenames

    print: (match) =>
      @subscribers.emit 'print', input: match, files: @getFiles(match.input)

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
