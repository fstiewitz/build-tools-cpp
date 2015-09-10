path = require 'path'

module.exports =
  class Command
    project: ''
    name: ''
    command: ''
    wd: ''
    shell: false
    wildcards: false
    save_all: false
    close_success: false
    stdout: {}
    stderr: {}
    targetOf: []
    version: null

    constructor: ({@project, @name, @command, @wd, @shell, @wildcards, @save_all, close_success, @stdout, @stderr, @output, @targetOf, @version} = {}, _command, _wd) ->
      @command = _command if _command?
      @wd = _wd if _wd?
      @targetOf = [] if not @targetOf?
      @output = {} if not @output?
      @stdout = {} if not @stdout?
      @stderr = {} if not @stderr?
      @version = 3 if not @project?
      if not @version?
        @version = 1
        if @stdout.highlighting is 'hc'
          @stdout.profile = 'gcc_clang'
        if @stderr.highlighting is 'hc'
          @stderr.profile = 'gcc_clang'
      if @version < 2
        @version = 2
        @save_all = atom.config.get('build-tools.SaveAll')
        @close_success = if atom.config.get('build-tools.CloseOnSuccess') is -1 then false else true
      if @version < 3
        @version = 3
        delete @close_success
        @output =
          console:
            close_success: true
          linter: {}
      return

    getProject: ->
      @project

    baseName: (wd = '.') ->
      if (filename = @file(wd))?
        path.basename(filename)

    fileWithoutExtension: (wd = '.') ->
      if (filename = @file(wd))?
        path.basename(filename, path.extname(filename))

    folder: (wd = '.') ->
      if (filename = @file(wd))?
        path.dirname(filename)

    file: (wd = '.') ->
      path.relative(path.resolve(@project, wd), atom.workspace.getActiveTextEditor()?.getPath())

    replaceWildcards: ->
      command = @command
      wd = @wd
      if @wildcards
        if /%[fbde]/.test(@wd)
          if /%f/.test(@wd)
            wd = wd.replace /(\\)?(%f)/g, ($0, $1, $2) =>
              if $1 then $2 else @file(null)

          if /%b/.test(@wd)
            wd = wd.replace /(\\)?(%b)/g, ($0, $1, $2) =>
              if $1 then $2 else @baseName(null)

          if /%d/.test(@wd)
            wd = wd.replace /(\\)?(%d)/g, ($0, $1, $2) =>
              if $1 then $2 else @folder(null)

          if /%e/.test(@wd)
            wd = wd.replace /(\\)?(%e)/g, ($0, $1, $2) =>
              if $1 then $2 else @fileWithoutExtension(null)

        if /%[fbde]/.test(@command)
          if /%f/.test(@command)
            command = command.replace /(\\)?(%f)/g, ($0, $1, $2) =>
              if $1 then $2 else @file(wd)

          if /%b/.test(@command)
            command = command.replace /(\\)?(%b)/g, ($0, $1, $2) =>
              if $1 then $2 else @baseName(wd)

          if /%d/.test(@command)
            command = command.replace /(\\)?(%d)/g, ($0, $1, $2) =>
              if $1 then $2 else @folder(wd)

          if /%e/.test(@command)
            command = command.replace /(\\)?(%e)/g, ($0, $1, $2) =>
              if $1 then $2 else @fileWithoutExtension(wd)
      {command, wd}

    getSpawnInfo: ->
      {command, wd} = @replaceWildcards()
      cwd = path.resolve(@project, wd)
      if @shell
        sh = atom.config.get('build-tools.ShellCommand')
        sha = sh.split(' ')
        args = sha.slice(1)
        args.push(command)
        {cmd: sha[0], args, wd: cwd, env: process.env}
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
              args[args.length - 1] += ' ' + cmd_list[0]
            qi = getQuoteIndex(cmd_list[0])
            if (qi = getQuoteIndex(cmd_list[0]))?
              if instring
                instring = false
              else
                if cmd_list[0].substr(qi.index + 1).indexOf(qi.character) is -1
                  instring = true
            cmd_list.shift()
          args
        args = split command
        reg = /[\"\']/
        for a, i in args
          if reg.test(a[0]) and reg.test(a[a.length - 1])
            args[i] = a.slice(1, -1)
        cmd = args[0]
        args = args.slice(1)
        {cmd, args, wd: cwd, env: process.env}
