path = null

baseName = (project, wd = '.') ->
  if (filename = file(project, wd))?
    path.basename(filename)

fileWithoutExtension = (project, wd = '.') ->
  if (filename = file(project, wd))?
    path.basename(filename, path.extname(filename))

folder = (project, wd = '.') ->
  if (filename = file(project, wd))?
    path.dirname(filename)

file = (project, wd = '.') ->
  try
    path.relative(path.resolve(project, wd), atom.workspace.getActiveTextEditor()?.getPath())

error = 'Could not get path from active text editor'

module.exports =

  name: 'Wildcards'

  activate: ->
    path = require 'path'

  deactivate: ->
    path = null

  preSplit: (command) ->
    new Promise((resolve, reject) ->
      if /%[fbde]/.test(command.wd)
        if /%f/.test(command.wd)
          command.wd = command.wd.replace /(\\)?(%f)/g, ($0, $1, $2) ->
            if $1 then $2 else file(command.project, null) ? reject(error)

        if /%b/.test(command.wd)
          command.wd = command.wd.replace /(\\)?(%b)/g, ($0, $1, $2) ->
            if $1 then $2 else baseName(command.project, null) ? reject(error)

        if /%d/.test(command.wd)
          command.wd = command.wd.replace /(\\)?(%d)/g, ($0, $1, $2) ->
            if $1 then $2 else folder(command.project, null) ? reject(error)

        if /%e/.test(command.wd)
          command.wd = command.wd.replace /(\\)?(%e)/g, ($0, $1, $2) ->
            if $1 then $2 else fileWithoutExtension(command.project, null) ? reject(error)

      if /%[fbde]/.test(command.command)
        if /%f/.test(command.command)
          command.command = command.command.replace /(\\)?(%f)/g, ($0, $1, $2) ->
            if $1 then $2 else file(command.project, command.wd) ? reject(error)

        if /%b/.test(command.command)
          command.command = command.command.replace /(\\)?(%b)/g, ($0, $1, $2) ->
            if $1 then $2 else baseName(command.project, command.wd) ? reject(error)

        if /%d/.test(command.command)
          command.command = command.command.replace /(\\)?(%d)/g, ($0, $1, $2) ->
            if $1 then $2 else folder(command.project, command.wd) ? reject(error)

        if /%e/.test(command.command)
          command.command = command.command.replace /(\\)?(%e)/g, ($0, $1, $2) ->
            if $1 then $2 else fileWithoutExtension(command.project, command.wd) ? reject(error)
      resolve()
    )
