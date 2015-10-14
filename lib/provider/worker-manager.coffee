module.exports =
  activate: ->
    @workers = {}

  deactivate: ->
    for k in Object.keys(@workers)
      for j in Object.keys(@workers[k])
        @workers[k][j]?.stop()
    @workers = {}

  getWorker: (command) ->
    @workers[command.project] ?= {}
    return worker if (worker = @workers[command.project][command.name])?
    @createWorker(command)

  createWorker: (command) ->
    new Promise((resolve, reject) =>
      command.getQueue().run().then ((worker) =>
        @workers[command.project][command.name] = worker
        worker.onFinishedQueue => @removeWorker(command)
        resolve(worker)
      ), reject
    )

  removeWorker: (command) ->
    @workers[command.project] ?= {}
    @workers[command.project][command.name]?.stop()
    @workers[command.project][command.name] = null
