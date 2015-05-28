path = require 'path'
fs = require 'fs-plus'
msgs = require './message-list.coffee'

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

  extInList: (extlist, filename) ->
    for item in extlist
      item_unquote = @removeQuotes item
      if item_unquote is filename.substr(filename.length-item_unquote.length)
        return true
    return false

  getProjectPath: ->
    projdir = atom.project.getPaths()[0]
    if not projdir? #Project path available? - If not use file path
      editor = atom.workspace.getActiveTextEditor()?.getPath()
      if editor? #File path available?
        return path.dirname(editor)
      else
        return ''
    return projdir

  getAbsPath: (filepath) ->
    bf = msgs.settings?.getBuildFolder()
    if not bf?
      bf = "."
    fp = path.resolve(@getProjectPath(),bf,filepath)
    return fp if fs.existsSync(fp)
    return ''

  unlint: ->
      msgs.messages = []
      @nolintlines = []

  lint: (line) ->
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

  parseGCC: (line) ->
    @lint line
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
      @nolintlines = []
      return @status
    else if @continue_status #Continue treating as error message?
      return @status
    else
      return ''

  clearVars: ->
    @rollover = ''
    @status = ''
    @nostatuslines = ''
    @nolintlines = []
    @continue_status = false
