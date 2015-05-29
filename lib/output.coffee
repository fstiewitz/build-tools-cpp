{$$} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'

module.exports =
  set: (cmd, projectpath) ->
    @settings = {
      path: projectpath,
      command: cmd.command,
      wd: cmd.wd,
      stdout: cmd.stdout,
      stderr: cmd.stderr
    }

  clear: ->
    @rollover = ''
    @status = ''
    @nostatuslines = ''
    @continue_status = false
    @settings = {}

  getAbsPath: (relpath, folder) ->
    return fp if fs.existsSync(fp=path.resolve(folder, relpath))

  getFileNames: (line,wd) ->
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
          if (fp = @getAbsPath(match[1],wd))?
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

            filenames.push {
              filename: fp
              row: row
              col: col
              start: line.indexOf(match[1],new_start)
              end: end
            }
            new_start = end
    filenames

  buildHTML: (message,status,stream)->
    mark = @settings[stream].file
    wd = @settings.wd
    if mark
      filenames = @getFileNames message, wd
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

  parseTags: (line) ->
    if (r=/(error|warning):/g.exec(line))? then r[1] else ''

  parseAndPrint: (line, stream, print) ->
    format = @settings[stream].highlighting
    if format is 'nh'
      stat = ''
    else if format is 'ha'
      stat = 'warning'
    else if format is 'ht'
      stat = @parseTags line
    else if format is 'hc'
      stat = @parseGCC line

    if stat is '' and format is 'hc'
      @nostatuslines = @nostatuslines + line + "\n"
    else
      if @nostatuslines isnt ''
        for l in @nostatuslines.split("\n").slice(0,-1)
          print (@buildHTML l, stat, stream)
          @nostatuslines = ''
      print (@buildHTML line, stat, stream)

  popLines: (print)->
    for l in @nostatuslines.split("\n")
      if l isnt ''
        print (@buildHTML l,'')
    @nostatuslines = ''

  toLine: (line, stream, print) ->
    lines = line.split("\n")

    if lines.length is 1 #No '\n' found -> incomplete line -> add to rollover
      @rollover = @rollover + lines[0]
    else if lines.length is 2 and lines[1] is ''
      if @rollover isnt '' #If incomplete line in @rollover
        lines[0] = @rollover + lines[0] #Finish line
        @rollover = ''

      @parseAndPrint lines[0], stream, print
    else
      if @rollover isnt ''
        lines[0] = @rollover + lines[0]
        @rollover = ''

      for l in lines.slice(0,-1) #For each element except last one
        @toLine l+"\n", stream, print #Recursive call
      last = lines[lines.length-1] #Get last element
      if last isnt '' #If last element not empty -> start of unfinished line
        @rollover = last
