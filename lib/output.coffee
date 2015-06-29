{$$} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'
Profiles = require './profiles/profiles'

module.exports =
  class Output
    settings: null
    status: ''
    nostatuslines: ''
    continue_status: ''
    nolintlines: []
    printfunc: null

    constructor: (command, stream, printfunc) ->
      @settings =
        project: command.project
        command: command.command
        wd: command.wd
        shell: command.shell
        stream: command[stream]
      @printfunc = printfunc
      if @settings.stream.profile?
        @profile = new Profiles[@settings.stream.profile]
        @profile.clear()

    destroy: ->
      if @profile?
        matches = @profile.finish()
        for match in matches
          @printfunc(@buildHTML match.input, if match.highlighting? then match.highlighting else match.type)

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
          @printfunc @buildHTML match.input, if match.highlighting? then match.highlighting else match.type
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
        stat = if status? then "text-#{status}" else ""
        @div class:"bold #{stat}", =>
          if filenames? and filenames.length isnt 0
            prev = -1
            for {file, row, col, start, end} in filenames
              @span message.substr(prev+1,start - (prev + 1))
              @span class:"filelink highlight-#{stat}", name:file, row:row, col:col, message.substr(start,end - start + 1)
              prev = end
            @span message.substr(prev+1) if prev isnt message.length - 1
          else
            @span message

    getAbsPath: (relpath) ->
      return fp if fs.existsSync(fp=path.resolve(@settings.project, @settings.wd, relpath))
