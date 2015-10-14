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
      p = command.getQueue().run()
      p.then (worker) =>
        @workers[command.project][command.name] = worker
        worker.onFinishedQueue => @removeWorker(command)
        resolve(worker)
      p.catch (error) ->
        console.log error.message
        reject(error)
    )

  removeWorker: (command) ->
    @workers[command.project] ?= {}
    @workers[command.project][command.name]?.stop()
    @workers[command.project][command.name] = null
