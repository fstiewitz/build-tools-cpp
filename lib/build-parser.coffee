path = require 'path'
fs = require 'fs-plus'

module.exports=
  getWD: (projdir, build_folder) ->
    if path.isAbsolute(build_folder)
      if fs.isDirectorySync build_folder
        return build_folder
    else
      if projdir isnt ''
        p = path.join(projdir,build_folder)
        if fs.isDirectorySync p
          return p
    return ''

  importantFiles: {
    "make": "Makefile"
    "cmake": "CMakeLists.txt"
    "autoreconf": "configure.ac"
    "make-option": "-f" #Option to set custom name, here: `make -f some_file`
    "cmake-folder": "-1" #Argument to set custom file/folder, here: cmake .. ( -1 is last element )
  }

  # Public: Look for known dependencies before executing a command
  #
  # This method is used to look for files which are required to run a command.
  # Currently known:
  # * `make` requires `Makefile` or the name given with the `-f`-option
  # * `cmake` requires `CMakeLists.txt` in folder which is given as the last argument of the call
  # * `autoreconf` requires `configure.ac`
  #
  # build_folder - the {String} folder in which the command is executed
  # command - the {String} command to execute
  # args - {String} command line arguments
  #
  # Returns `""` if all dependencies are met
  # Returns `filename` if `filename` is required but does not exist
  # Returns `undefined` if `args` is wrong ( e.g. `make -f` which requires a path to the correct `Makefile` )
  hasDependencies: (build_folder, command, args) ->
    if (defaultFile = @importantFiles[command])?
      if (option=@importantFiles[command+"-option"])? and (index= ( ->
        for a,index in args
          if a.indexOf(option) is 0
            return index
        return -1
        )() ) isnt -1
        if (filename = args[index].slice(option.length)) isnt ""
          if fs.existsSync(filename = path.join(build_folder,filename))
            return ""
          else
            return filename
        else if (filename = args[index+1])?
            if fs.existsSync(filename = path.join(build_folder,filename))
              return ""
            else
              return filename
        else
          return filename
      else if (bfIndex = @importantFiles[command+"-folder"])? and (f = args.slice(parseInt(bfIndex))[0])?
        filename = path.join(build_folder,f,defaultFile)
        if fs.existsSync(filename)
          return ""
        else
          return filename
      else
        filename = path.join(build_folder,defaultFile)
        if fs.existsSync(filename)
          return ""
        else
          return filename
    else
      return ""

  extInList: (extlist, filename) ->
    llist = extlist.split(',')
    for item in llist
      item_unquote = @removeQuotes item
      if item_unquote is filename.substr(filename.length-item_unquote.length)
        return true
    return false

  getProjectPath: ->
    projdir = atom.project.getPath()
    if not projdir? #Project path available? - If not use file path
      editor = atom.workspace.getActiveEditor()?.getPath()
      if editor? #File path available?
        return path.dirname(editor)
      else
        return ''
    return projdir

  getAbsPath: (filepath) ->
    fp = path.resolve(@getProjectPath(),filepath)
    return fp if fs.existsSync(fp)
    return ''

  getFileNames: (line) ->
    filenames = []
    byspace = line.split(' ')
    return filenames if byspace.length <= 1
    new_start = 0
    for e,index in byspace
      if e isnt ''
        bycolon = e.split(':')
        if bycolon.length > 1
          if @extInList atom.config.get('build-tools-cpp.SourceFileExtensions'), bycolon[0]
            fp = @getAbsPath bycolon[0]
            if fp isnt ''
              end = line.indexOf(bycolon[0]) + bycolon[0].length - 1
              row = 0
              col = 0
              validRow = /^[\d]+$/.test(bycolon[1])
              validCol = /^[\d]+$/.test(bycolon[2])
              if validRow
                row = bycolon[1]
                if validCol
                  col = bycolon[2]
                  end = line.indexOf(bycolon[0]) + (bycolon[0]+bycolon[1]+bycolon[2]).length + 1
                else
                  end = line.indexOf(bycolon[0]) + (bycolon[0]+bycolon[1]).length

              filenames.push {
                filename: fp
                row: row
                col: col
                start: line.indexOf(e,new_start)
                end: end
              }
              new_start = end
    return filenames


  parseGCC: (line) ->
    if line.indexOf('error:') isnt -1 #Check for errors
      @continue_status = true
      @status = 'error'
      return 'error'
    else if line.indexOf('warning:') isnt -1 #Check for warnings
      @continue_status = true
      @status = 'warning'
      return 'warning'
    else if /^[\^\s~]+$/.test(line) #Reached delimiter for error messages?
      @continue_status = false
      return @status
    else if @continue_status #Continue treating as error message?
      return @status
    else
      return ''

  clearVars: ->
    @rollover = ''
    @status = ''
    @nostatuslines = ''
    @continue_status = false

  buildHTML: (message,status)->
    l = '<div'
    if status isnt ''
      l += " class=\"bold text-#{status}\">"
    else
      l += ">"
    filenames = @getFileNames message
    prev = -1
    if filenames.length?
      for file in filenames
        l += message.substr(prev+1,file.start - (prev + 1))
        l += "<div class=\"filelink inline-block highlight-#{status}\" name=\"#{file.filename}\""
        l += "row=\"#{file.row}\" col=\"#{file.col}\">"
        l += message.substr(file.start,file.end - file.start + 1)
        l += "</div>"
        prev = file.end
      if prev isnt message.length - 1
        l += message.substr(prev+1)
    else
      l += message
    l += "</div>"
    return l

  removeQuotes: (line) ->
    return line.replace(/[\"]/g,'') if line.search('"') isnt -1
    return line.replace(/[\']/g,'')

  parseAndPrint: (line,script,printfunc) ->
    if script is 'make'
      stat = @parseGCC line
    else
      stat = ''

    if stat is '' and script isnt ''
      @nostatuslines = @nostatuslines + line + "\n"
    else
      if @nostatuslines isnt ''
        for l in @nostatuslines.split("\n").slice(0,-1)
          printfunc (@buildHTML l,stat)
        @nostatuslines = ''
      printfunc (@buildHTML line,stat)

  poplines: (printfunc)->
    for l in @nostatuslines.split("\n")
      if l isnt ''
        printfunc (@buildHTML l,'')
    @nostatuslines = ''

  toLine: (line, script, printfunc) ->
    lines = line.split("\n")

    if lines.length is 1 #No '\n' found -> incomplete line -> add to rollover
      @rollover = @rollover + lines[0]
    else if lines.length is 2 and lines[1] is ''
      if @rollover isnt '' #If incomplete line in @rollover
        lines[0] = @rollover + lines[0] #Finish line
        @rollover = ''

      @parseAndPrint lines[0],script,printfunc
    else
      if @rollover isnt ''
        lines[0] = @rollover + lines[0]
        @rollover = ''

      for l in lines.slice(0,-1) #For each element except last one
        @toLine l+"\n", script, printfunc #Recursive call
      last = lines[lines.length-1] #Get last element
      if last isnt '' #If last element not empty -> start of unfinished line
        @rollover = last
