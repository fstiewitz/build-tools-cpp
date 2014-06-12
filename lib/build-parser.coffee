path = require 'path'
fs = require 'fs-plus'

module.exports=
  getWD: (projdir, build_folder) ->
    p = path.join(projdir,build_folder)
    if fs.isDirectorySync p
      return p
    else
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
          if a.indexOf(option) == 0
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

  extInList: (filename) ->
    lstring = atom.config.get('build-tools-cpp.SourceFileExtensions')
    llist = lstring.split(',')
    for item in llist
      item_unquote = @removeQuotes item
      if item_unquote == filename.substr(filename.length-item_unquote.length)
        return true
    return false

  getAbsPath: (filepath) ->
    spath = "."
    i=0
    fpath = filepath
    while not fs.isFileSync(fpath)
      if i>5 then break
      fpath = path.join(atom.project.getPath(),spath,filepath)
      spath = path.join(spath,"x")
      i=i+1
    return fpath if i<=5
    return ''

  getFileNames: (line) ->
    filenames = []
    byspace = line.split(' ')
    return filenames if byspace.length <= 1
    new_start = 0
    for e,index in byspace
      if e != ''
        bycolon = e.split(':')
        if bycolon.length > 1
          if @extInList bycolon[0]
            fp = @getAbsPath bycolon[0]
            if fp != ''
              if bycolon.length == 1 or bycolon[1] == '' #filename.cpp
                end = line.indexOf(bycolon[0]) + bycolon[0].length - 1
                row = 0
                col = 0
              else if bycolon.length == 2
                if isNaN(new Number(bycolon[1])) or bycolon[2] == ''
                  end = line.indexOf(bycolon[0]) + bycolon[0].length - 1
                  row = 0
                  col = 0
                else #filename.cpp:10
                  end = line.indexOf(bycolon[0]) + e.length - 1
                  row = bycolon[1]
                  col = 1
              else if bycolon.length >= 3
                if isNaN(new Number(bycolon[1])) #filename.cpp:something:abc
                  end = line.indexOf(bycolon[0]) + bycolon[0].length - 1
                  row = 0
                  col = 0
                else
                  if isNaN(new Number(bycolon[2])) #filename.cpp:10:something
                    end = line.indexOf(bycolon[0]) + \
                    (bycolon[0]+bycolon[1]).length
                    row = bycolon[1]
                    col = 1
                  else #filename.cpp:10:20
                    end = line.indexOf(bycolon[0]) + \
                    (bycolon[0]+bycolon[1]+bycolon[2]).length + 1
                    row = bycolon[1]
                    col = bycolon[2]

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
    if line.indexOf('error:') != -1 #Check for errors
      @continue_status = true
      @status = 'lineerror'
      return 'lineerror'
    else if line.indexOf('warning:') != -1 #Check for warnings
      @continue_status = true
      @status = 'linewarning'
      return 'linewarning'
    else if line.trim() == '^' #Reached delimiter for error messages?
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
    @c = null

  buildHTML: (message,status)->
    l = '<div'
    if status != ''
      l += " class=\"#{status}\">"
    else
      l += ">"
    filenames = @getFileNames message
    prev = -1
    if filenames.length?
      for file in filenames
        l += message.substr(prev+1,file.start - (prev + 1))
        l += "<span class=\"filelink\" name=\"#{file.filename}\""
        l += "row=\"#{file.row}\" col=\"#{file.col}\">"
        l += message.substr(file.start,file.end - file.start + 1)
        l += "</span>"
        prev = file.end
      if prev != message.length - 1
        l += message.substr(prev+1)
    else
      l += message
    l += "</div>"
    return l

  removeQuotes: (line) ->
    c1 = line.indexOf("\"")
    if c1 != -1
      c = "\""
    else
      c1 = line.indexOf("\'")
      if c1 != -1
        c = "\'"
      else
        return line
    c2 = line.substr(c1+1).indexOf(c)
    return '' if c2 == -1
    l = ''
    l += line.substr(0,c1) if c1 > 0
    l += line.substr(c1+1,c2) if c2 > 0
    l += line.substr(c2+c1+2) if c2+c1+2 < line.length - 1
    return l

  parseAndPrint: (line,script,printfunc) ->
    if script == 'make'
      stat = @parseGCC line
    else
      stat = ''

    if stat == '' and script != ''
      @nostatuslines = @nostatuslines + line + "\n"
    else
      if @nostatuslines != ''
        for l in @nostatuslines.split("\n").slice(0,-1)
          printfunc (@buildHTML l,stat)
        @nostatuslines = ''
      printfunc (@buildHTML line,stat)

  toLine: (line, script, printfunc) ->
    lines = line.split("\n")

    if lines.length == 1 #No '\n' found -> incomplete line -> add to rollover
      @rollover = @rollover + lines[0]
    else if lines.length == 2 and lines[1] == ''
      if @rollover != '' #If incomplete line in @rollover
        lines[0] = @rollover + lines[0] #Finish line
        @rollover = ''

      @parseAndPrint lines[0],script,printfunc
    else
      if @rollover != ''
        lines[0] = @rollover + lines[0]
        @rollover = ''

      for l in lines.slice(0,-1) #For each element except last one
        @toLine l+"\n", script, printfunc #Recursive call
      last = lines[lines.length-1] #Get last element
      if last != '' #If last element not empty -> start of unfinished line
        @rollover = last
