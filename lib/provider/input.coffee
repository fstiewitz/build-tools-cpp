path = require 'path'
fs = require 'fs'
ProjectConfig = require './project'
Command = require './command'

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
  currentWorker: null

  deactivate: ->
    SelectionView = null
    selectionview = null

    AskView = null
    askview = null

  key: (id) ->
    return unless (p = atom.workspace.getActiveTextEditor()?.getPath())?
    getFirstConfig(path.resolve(path.dirname(p))).then(({folderPath, filePath}) =>
      p = getProjectConfig(folderPath, filePath).getCommandByIndex(id)
      p.catch (error) -> atom.notifications?.addError error
      p.then (command) =>
        @run(command)
    )

  keyAsk: (id) ->
    return unless (p = atom.workspace.getActiveTextEditor()?.getPath())?
    getFirstConfig(path.resolve(path.dirname(p))).then(({folderPath, filePath}) =>
      p = getProjectConfig(folderPath, filePath).getCommandByIndex(id)
      p.catch (error) -> atom.notifications?.addError error
      p.then (command) =>
        AskView ?= require '../view/ask-view'
        askview = new AskView(command.command, (c) =>
          rc = new Command(command)
          rc.command = c
          @run(rc)
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
      project.getCommandNameObjects().then (commands) =>
        selectionview.setItems commands
        selectionview.callback = ({id, origin}) =>
          command = project.getCommandById origin, id
          @run command
    )
    q.catch -> selectionview.setError('Could not load project configuration')

  run: (command) ->
    p = command.getQueue().run()
    @cancel()
    p.then (@currentWorker) =>
      @currentWorker.run()
      @currentWorker.onFinishedQueue => @currentWorker = null
    p.catch (error) =>
      atom.notifications?.addError error
      @currentWorker = null

  input: (command) ->
    new Promise((resolve, reject) ->
      if @currentWorker? and not @currentWorker.finished
        @currentWorker.onFinishedQueue ->
          resolve(new Command(command).getQueue())
      else
        resolve(new Command(command).getQueue())
    )

  cancel: ->
    @currentWorker?.stop()

  getFirstConfig: getFirstConfig
