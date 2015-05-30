path = require 'path'

module.exports =
  class Command
    project: ''
    name: ''
    command: ''
    wd: ''
    shell: ''
    stdout: {}
    stderr: {}

    constructor: ({@project,@name,@command,@wd,@shell,@stdout,@stderr}) ->
      return

    parseCommand: ->
      if @shell
        sh = atom.config.get('build-tools-cpp.ShellCommand')
        sha = sh.split(' ')
        command.cmd = sha[0]
        args = sha.slice(1)
        args.push(@command)
        {cmd: sha[0], args, env: process.env, cwd: path.resolve(@project, @wd)}
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
        args = split @command
        reg = /[\"\']/
        for a,i in args
          if reg.test(a[0]) and reg.test(a[a.length - 1])
            args[i]=a.slice(1,-1)
        cmd = args[0]
        args = args.slice(1)
        {cmd, args, env: process.env, cwd: path.resolve(@project, @wd)}
