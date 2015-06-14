path = require 'path'

module.exports =
  class Command
    project: ''
    name: ''
    command: ''
    wd: ''
    shell: false
    wildcards: false
    stdout: {}
    stderr: {}
    targetOf: []

    constructor: ({@project,@name,@command,@wd,@shell,@wildcards,@stdout,@stderr,@targetOf}) ->
      @targetOf = [] if not @targetOf?
      return

    getProject: ->
      @project

    baseName: ->
      if (filename=@file())?
        path.basename(filename)

    fileWithoutExtension: ->
      if (filename=@file())?
        path.basename(filename,path.extname(filename))

    folder: ->
      if (filename=@file())?
        path.dirname(filename)

    file: ->
      path.relative(path.resolve(@project,@wd),atom.workspace.getActiveTextEditor()?.getPath())

    replaceWildcards: ->
      command = @command
      wd = @wd
      if @wildcards
        if /%[fbde]/.test(@command)
          if /%f/.test(@command)
            command = command.replace /(\\)?(%f)/g, ($0,$1,$2) =>
              if $1 then $2 else @file()

          if /%b/.test(@command)
            command = command.replace /(\\)?(%b)/g, ($0,$1,$2) =>
              if $1 then $2 else @baseName()

          if /%d/.test(@command)
            command = command.replace /(\\)?(%d)/g, ($0,$1,$2) =>
              if $1 then $2 else @folder()

          if /%e/.test(@command)
            command = command.replace /(\\)?(%e)/g, ($0,$1,$2) =>
              if $1 then $2 else @fileWithoutExtension()
        if /%[fbde]/.test(@wd)
          if /%f/.test(@wd)
            wd = wd.replace /(\\)?(%f)/g, ($0,$1,$2) =>
              if $1 then $2 else @file()

          if /%b/.test(@wd)
            wd = wd.replace /(\\)?(%b)/g, ($0,$1,$2) =>
              if $1 then $2 else @baseName()

          if /%d/.test(@wd)
            wd = wd.replace /(\\)?(%d)/g, ($0,$1,$2) =>
              if $1 then $2 else @folder()

          if /%e/.test(@wd)
            wd = wd.replace /(\\)?(%e)/g, ($0,$1,$2) =>
              if $1 then $2 else @fileWithoutExtension()
      {command,wd}

    parseCommand: ->
      {command,wd} = @replaceWildcards()
      if @shell
        sh = atom.config.get('build-tools-cpp.ShellCommand')
        sha = sh.split(' ')
        args = sha.slice(1)
        args.push(command)
        {cmd: sha[0], args, env: process.env, cwd: path.resolve(@project, wd)}
      else
        split = (cmd_string) ->
          args = []
          cmd_list = cmd_string.split(' ')
          instring = false
          getQuoteIndex = (line) ->
            return {index: c, character: '"'} if (c = line.indexOf('"')) isnt -1
            return {index: c, character: "'"} if (c = line.indexOf("'")) isnt -1
          while (cmd_list.length isnt 0)
            if not instring
              args.push cmd_list[0]
            else
              args[args.length-1] += ' ' + cmd_list[0]
            qi = getQuoteIndex(cmd_list[0])
            if (qi = getQuoteIndex(cmd_list[0]))?
              if instring
                instring = false
              else
                if cmd_list[0].substr(qi.index+1).indexOf(qi.character) is -1
                  instring = true
            cmd_list.shift()
          args
        args = split command
        reg = /[\"\']/
        for a,i in args
          if reg.test(a[0]) and reg.test(a[a.length - 1])
            args[i]=a.slice(1,-1)
        cmd = args[0]
        args = args.slice(1)
        {cmd, args, env: process.env, cwd: path.resolve(@project, wd)}
