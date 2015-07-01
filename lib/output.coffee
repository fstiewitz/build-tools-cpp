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
      @nostatuslines = []
      if @settings.stream.profile?
        @profile = new Profiles[@settings.stream.profile]
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
        matches = @profile.in line
        for match in matches
          if match.wait is false
            line = @nostatuslines.splice(0,1)
            new_line = @buildHTML match.input, if match.highlighting? then match.highlighting else match.type
            $(line).prop('class', $(new_line).prop('class'))
            $(line).html($(new_line).html())
            @profile.lint @getAbsPath(match.file), match if @settings.stream.lint and match.file?
          else
            line = @printfunc @buildHTML match.input, if match.highlighting? then match.highlighting else match.type
            @nostatuslines.push line if match.wait is true
            @profile.lint @getAbsPath(match.file), match if @settings.stream.lint and not match.wait? and match.file?
      else
        @printfunc @buildHTML line

    parseTags: (line) ->
      if (r=/(error|warning):/g.exec(line))? then r[1] else ''

    buildHTML: (message, status) ->
      if @settings.stream.file and @profile?
        filenames = []
        for match in @profile.files message
          match.file = @getAbsPath(match.file)
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

    getAbsPath: (relpath) ->
      return fp if fs.existsSync(fp=path.resolve(@settings.project, @settings.wd, relpath))
