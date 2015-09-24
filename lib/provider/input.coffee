path = require 'path'
fs = require 'fs'
ProjectConfig = require './project'

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

  key: (id) ->
    return unless (path = atom.workspace.getActiveTextEditor()?.getPath())?
    getFirstConfig(path.resolve(path.dirname(path))).then (folder, file) ->
      p = getProjectConfig(folder, file).getCommandByIndex(id)?.getQueue().run()
      p.then (@currentWorker) => @currentWorker.run()
      p.catch (error) =>
        atom.notifications?.addError error
        @currentWorker = null

  cancel: ->
    @currentWorker?.stop()

  getFirstConfig: getFirstConfig
