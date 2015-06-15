{$$} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'

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
      @nostatuslines = ''
      @nolintlines = []

    destroy: ->
      for l in @nostatuslines.split("\n")
        if l isnt ''
          item = @buildHTML l, ''
          @printfunc item

    in: (message) ->
      lines = message.split('\n')
      for line in lines
        if line isnt ''
          @parse line

    parse: (line) ->
      format = @settings.stream.highlighting
      if format is 'nh'
        stat = ''
      else if format is 'ha'
        stat = 'warning'
      else if format is 'ht'
        stat = @parseTags line
        @lint line if @settings.stream.lint
      else if format is 'hc'
        stat = @parseGCC line
        @lint line if @settings.stream.lint

      if stat is '' and format is 'hc'
        @nostatuslines = @nostatuslines + line + "\n"
      else
        if @nostatuslines isnt ''
          for l in @nostatuslines.split("\n").slice(0,-1)
            item = @buildHTML l, stat
            @printfunc item
          @nostatuslines = ''
        item = @buildHTML line, stat
        @printfunc item

    parseTags: (line) ->
      if (r=/(error|warning):/g.exec(line))? then r[1] else ''

    parseGCC: (line) ->
      if (r=/(error|warning):/g.exec(line))?
        @continue_status = true
        @status = r[1]
        return r[1]
      else if /^[\^\s~]+$/.test(line) #Reached delimiter for error messages?
        @continue_status = false
        return @status
      else if @continue_status #Continue treating as error message?
        return @status
      else
        return ''

    buildHTML: (message, status) ->
      if @settings.stream.file
        filenames = @getFileNames message
      $$ ->
        stat = if status isnt '' then "text-#{status}" else ""
        @div class:"bold #{stat}", =>
          if filenames?.length?
            prev = -1
            for {filename, row, col, start, end} in filenames
              @span message.substr(prev+1,start - (prev + 1))
              stat = "highlight-#{status}" if stat isnt ""
              @span class:"filelink #{stat}", name:filename, row:row, col:col, message.substr(start,end - start + 1)
              prev = end
            @span message.substr(prev+1) if prev isnt message.length - 1
          else
            @span message

    getFileNames: (line) ->
      filenames = []
      byspace = line.split(' ')
      return filenames if byspace.length <= 1
      extensions = atom.config.get('build-tools-cpp.SourceFileExtensions').sort().reverse().join('|')
      extensions = extensions.replace(/\./g,"\\.")
      regstring = "([\\S]+(?:" + extensions + "))(?::([\\d]+)(?::([\\d]+))?)?"
      regex = new RegExp(regstring)
      new_start = 0
      for e, index in byspace
        if e isnt ''
          if (match = regex.exec(e))?
            if (fp = @getAbsPath(match[1]))?
              end = line.indexOf(match[1],new_start) + match[1].length - 1
              row = 0
              col = 1
              if match[2]?
                row = match[2]
                if match[3]?
                  col = match[3]
                  end = end + match[2].length + match[3].length + 2
                else
                  end = end + match[2].length + 1

              filenames.push
                filename: fp
                row: row
                col: col
                start: line.indexOf(match[1],new_start)
                end: end
              new_start = end
      filenames

    getAbsPath: (file) ->
      return fp if fs.existsSync(fp=path.resolve(@settings.project, @settings.wd, file))

    lint: (line) ->
      msgs = require './linter-list'
      extensions = atom.config.get('build-tools-cpp.SourceFileExtensions').sort().reverse().join('|')
      extensions = extensions.replace(/\./g,"\\.")
      regstring = "([\\S]+(?:" + extensions + ")):([\\d]+)(?::[\\d]+)?:[\\w\\s]*(error|warning):([\\S\\s]+)"
      regstring_file_included = "(?:In file included from|from) ([\\S]+(?:" + extensions + ")):([\\d]+)(?::[\\d]+)?[:,]"
      regex = new RegExp(regstring)
      regex_file_included = new RegExp(regstring_file_included)
      if ( r = regex.exec(line))?
        if @nolintlines?
          for line in @nolintlines
            match = [line[0],line[1],line[2],r[3],r[4]]
            if msgs.messages[path.basename(match[1])]?
              msgs.messages[path.basename(match[1])].push(match)
            else
              msgs.messages[path.basename(match[1])] = [match]
        @nolintlines = []
        if msgs.messages[path.basename(r[1])]?
          msgs.messages[path.basename(r[1])].push(r)
        else
          msgs.messages[path.basename(r[1])] = [r]
      else if (r = regex_file_included.exec(line))?
        @nolintlines.push(r)
