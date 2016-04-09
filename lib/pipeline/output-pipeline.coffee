XRegExp = require('xregexp').XRegExp
Modifiers = require '../stream-modifiers/modifiers'

{Emitter} = require 'atom'

fs = require 'fs-plus'
path = require 'path'

module.exports =
  class OutputPipeline

    constructor: (@settings, @stream) ->
      @subscribers = new Emitter
      @pipeline = []
      for {name, config} in @stream.pipeline
        if (c = Modifiers.modules[name])?
          if c.modifier.prototype.modify?
            Modifiers.activate name
            @pipeline.push new c.modifier(config, @settings, this)
        else
          atom.notifications?.addError "Could not find stream modifier: #{name}"
      @perm = cwd: '.'

    destroy: ->
      mod.destroy?() for mod in @pipeline
      @pipeline = null
      @subscribers.dispose()
      @subscribers = null

    subscribeToCommands: (object, callback, command) ->
      @subscribers.on command, (o) -> object[callback](o)

    getFiles: (match) ->
      filenames = []
      for mod in @pipeline
        continue unless mod.getFiles?
        for _match in mod.getFiles(temp: match, perm: @perm)
          if _match.file and (fp = @absolutePath _match.file)?
            _match.file = fp
            filenames.push _match
      return filenames

    finishLine: (td, input) ->
      if td.input isnt input or (files = @getFiles(td)).length isnt 0
        @print td, files
      else if td.type?
        @setType td
      if td.file?
        @lint td

    in: (_input) ->
      td = input: _input
      for mod in @pipeline
        return if mod.modify(temp: td, perm: @perm) isnt null
      @finishLine(td, _input)

    setType: (match) =>
      @subscribers.emit 'setType', match.highlighting ? match.type

    absolutePath: (relpath) =>
      return fp if fs.existsSync(fp = path.resolve(@settings.project, @settings.wd, @perm.cwd, relpath))

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

    print: (match, _files) =>
      unless _files?
        _files = @getFiles(match)
      @subscribers.emit 'print', input: match, files: _files

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
