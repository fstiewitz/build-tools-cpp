path = require 'path'

module.exports =
  getWD: (res) ->
    path.resolve(res.projectpath, res.cmd.wd)

  getQuoteIndex: (line) ->
    c1 = line.indexOf('"')
    if c1 isnt -1
      return {index: c1, character: '"'}
    c1 = line.indexOf("'")
    return {index: c1, character: "'"}

  split: (cmd_string) ->
      args = []
      cmd_list = cmd_string.split(' ')
      instring = false
      while (cmd_list.length isnt 0)
        if not instring
          args.push cmd_list[0]
        else
          args[args.length-1] += ' ' + cmd_list[0]
        qi = @getQuoteIndex(cmd_list[0])
        if qi.index isnt -1
          if instring
            instring = false
          else
            if cmd_list[0].substr(qi.index+1).indexOf(qi.character) is -1
              instring = true
        cmd_list.shift()
      return args

  getCommand: (cmd_string, shell) ->
    command = {
      cmd: "",
      args: [],
      env: {}
    }
    command.env = process.env
    if shell
      sh = atom.config.get('build-tools-cpp.ShellCommand')
      sha = sh.split(' ')
      command.cmd = sha[0]
      command.args = sha.slice(1)
      command.args.push(cmd_string)
    else
      args = @split cmd_string
      reg = /[\"\']/
      for a,i in args
        if reg.test(a[0]) and reg.test(a[a.length - 1])
          args[i]=a.slice(1,-1)
      command.cmd = args[0]
      command.args = args.slice(1)
    command
