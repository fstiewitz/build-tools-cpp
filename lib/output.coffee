{$,$$} = require 'atom-space-pen-views'
fs = require 'fs'
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
      for line in lines
        if line isnt ''
          @parse line

    parse: (line) ->
      format = @settings.stream.highlighting
      if format is 'ha'
        @printfunc @buildHTML line, 'warning'
      else if format is 'ht'
        @printfunc @buildHTML line, @parseTags line
      else if format is 'hc' and @profile?
        @profile.in line
      else
        @printfunc @buildHTML line

    parseTags: (line) ->
      if (r=/(error|warning):/g.exec(line))? then r[1] else ''

    buildHTML: (message, status) ->
      if @settings.stream.file and @profile?
        filenames = []
        for match in @profile.files message
          match.file = @absolutePath(match.file)
          filenames.push match
      $$ ->
        status = '' if not status?
        @div class:"bold text-#{status}", =>
          if filenames? and filenames.length isnt 0
            prev = -1
            for {file, row, col, start, end} in filenames
              @span message.substr(prev+1,start - (prev + 1))
              @span class:"filelink highlight-#{status}", name:file, row:row, col:col, message.substr(start,end - start + 1)
              prev = end
            @span message.substr(prev+1) if prev isnt message.length - 1
          else
            @span message

    absolutePath: (relpath) =>
      return fp if fs.existsSync(fp=path.resolve(@settings.project, @settings.wd, relpath))

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
          [row-1,0]
          [row-1,if match.col? then col-1 else 9999]
        ]
      }

    replacePrevious: (new_lines) =>
      start = @lines.length - new_lines.length
      for line, index in new_lines
        item = @buildHTML line.input, line.highlighting
        $(@lines[start + index]).prop('class', item.prop('class'))
        $(@lines[start + index]).html(item.html())

    print: (match) =>
      line = @printfunc @buildHTML match.input, if match.highlighting? then match.highlighting else match.type
      @lines.push line
