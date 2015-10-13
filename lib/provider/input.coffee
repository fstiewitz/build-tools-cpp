path = require 'path'
fs = require 'fs'
ProjectConfig = require './project'
Command = require './command'
Queue = require '../pipeline/queue'

WorkerManager = require './worker-manager'

SelectionView = null
selectionview = null

AskView = null
askview = null

getFirstConfig = (folder) ->
  new Promise((resolve, reject) ->
    _getFirstConfig folder, resolve , reject
  )

_getFirstConfig = (folder, resolve, reject) ->
  fs.exists (file = path.join(folder, '.build-tools.cson')), (exists) ->
    return resolve(folderPath: folder, filePath: file) if exists
    p = path.resolve(folder, '..')
    return _getFirstConfig path.resolve(folder, '..'), resolve, reject if p isnt folder
    reject()

getProjectConfig = (folder, file) ->
  new ProjectConfig(folder, file)

module.exports =

  activate: ->
    WorkerManager.activate()

  deactivate: ->
    WorkerManager.deactivate()
    SelectionView = null
    selectionview = null

    AskView = null
    askview = null

  key: (id) ->
    return unless (p = atom.workspace.getActiveTextEditor()?.getPath())?
    getFirstConfig(path.resolve(path.dirname(p))).then(({folderPath, filePath}) =>
      p = (c = getProjectConfig(folderPath, filePath)).getCommandByIndex(id)
      p.catch (error) -> atom.notifications?.addError error
      p.then (command) =>
        @run(command)
        c.destroy()
    )

  keyAsk: (id) ->
    return unless (p = atom.workspace.getActiveTextEditor()?.getPath())?
    getFirstConfig(path.resolve(path.dirname(p))).then(({folderPath, filePath}) =>
      p = (config = getProjectConfig(folderPath, filePath)).getCommandByIndex(id)
      p.catch (error) -> atom.notifications?.addError error
      p.then (command) =>
        AskView ?= require '../view/ask-view'
        askview = new AskView(command.command, (c) =>
          rc = new Command(command)
          rc.command = c
          @run(rc)
          config.destroy()
        )
    )

  selection: ->
    return unless (p = atom.workspace.getActiveTextEditor()?.getPath())?
    SelectionView ?= require '../view/selection-view'
    selectionview = new SelectionView
    selectionview.setLoading('Loading project configuration')
    q = getFirstConfig(path.resolve(path.dirname(p)))
    q.then(({folderPath, filePath}) =>
      selectionview.setLoading('Loading command list')
      project = getProjectConfig(folderPath, filePath)
      n = project.getCommandNameObjects()
      n.then (commands) =>
        selectionview.setItems commands
        selectionview.callback = ({id, pid}) =>
          p = project.getCommandById pid, id
          p.then (command) =>
            @run command
            project.destroy()
          p.catch (e) ->
            selectionview.setError e
            project.destroy()
      n.catch (error) ->
        selectionview.setError error
        project.destroy()
    )
    q.catch -> selectionview.setError('Could not load project configuration')

  run: (command) ->
    WorkerManager.removeWorker(command)
    p = WorkerManager.createWorker(command)
    p.then (worker) -> worker.run()
    p.catch (error) -> atom.notifications?.addError error

  inputCommand: (command) ->
    new Command(command).getQueue()

  inputQueue: (commands) ->
    _commands = []
    for command in commands
      _commands.push new Command(command)
    new Queue(_commands)

  cancel: ->
    WorkerManager.deactivate()

  getFirstConfig: getFirstConfig
