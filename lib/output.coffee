{$, $$} = require 'atom-space-pen-views'
fs = require 'fs-plus'
path = require 'path'
Profiles = require './profiles/profiles'

module.exports =
  class Output
    settings: null
    nostatuslines: []
    printfunc: null

    constructor: (command, stream, printfunc) ->
      @settings =
        project: command.project
        command: command.command
        wd: command.wd
        shell: command.shell
        stream: command[stream]
      @printfunc = printfunc
      @lines = []
      if @settings.stream.profile?
        @profile = new Profiles[@settings.stream.profile]({@print, @replacePrevious, @createMessage, @absolutePath})
        @profile.clear()

    in: (message) ->
      lines = message.split('\n')
      for line, index in lines
        if line isnt '' or (line is '' and index isnt lines.length - 1)
          @lines.push @printfunc @buildHTML line, ''
          @parse line

    parse: (line) ->
      format = @settings.stream.highlighting
      if format is 'ha'
        @print input: line, type: 'warning'
      else if format is 'ht'
        @print input: line, type: @parseTags line
      else if format is 'hc' and @profile?
        @profile.in line

    parseTags: (line) ->
      if (r = /(error|warning):/g.exec(line))? then r[1] else ''

    buildHTML: (message, status) ->
      if @settings.stream.file and @profile?
        filenames = []
        for match in @profile.files message
          match.file = @absolutePath(match.file)
          filenames.push match if fs.isFileSync match.file
      $$ ->
        status = '' if not status?
        status = 'info' if status is 'note'
        @div class: "bold text-#{status}", =>
          if filenames? and filenames.length isnt 0
            prev = -1
            for {file, row, col, start, end} in filenames
              @span message.substr(prev + 1, start - (prev + 1))
              @span class: "filelink highlight-#{status}", name: file, row: row, col: col, message.substr(start, end - start + 1)
              prev = end
            @span message.substr(prev + 1) if prev isnt message.length - 1
          else
            @span if message is '' then ' ' else message

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
      start = @lines.length - new_lines.length - 1
      for line, index in new_lines
        item = @buildHTML line.input, if line.highlighting? then line.highlighting else line.type
        $(@lines[start + index]).prop('class', item.prop('class'))
        $(@lines[start + index]).html(item.html())

    print: (match) =>
      line = @buildHTML match.input, if match.highlighting? then match.highlighting else match.type
      id = @lines.length - 1
      $(@lines[id]).prop('class', line.prop('class'))
      $(@lines[id]).html(line.html())
