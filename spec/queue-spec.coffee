Queue = require '../lib/pipeline/queue'
Modifiers = require '../lib/modifier/modifier'

describe 'Queue', ->
  queue = null
  command = null
  modifier = null

  beforeEach ->
    command = {
      project: '/home/fabian/.atom/packages/build-tools/spec/fixtures'
      name: 'Test'
      command: 'echo Hello World'
      wd: '.'
      env: {}
      modifier:
        test: {
          t: 1
        }
      stdout:
        highlighting: 'nh'
      stderr:
        highlighting: 'nh'
      output:
        console:
          close_success: false
      version: 1
    }
    out = {
      in: (queue) ->
        queue.queue[0].t = queue.queue[0].modifier.test.t
        return
    }
    modifier = Modifiers.addModule 'test', out
    queue = new Queue(command)

  afterEach ->
    modifier.dispose()

  describe 'On ::run', ->
    p = null
    w = null

    beforeEach ->
      p = queue.run()
      p.then (worker) -> w = worker
      waitsForPromise -> p

    it 'returns a valid QueueWorker', ->
      expect(w.queue.queue.length).toBe 1
      expect(w.queue.queue[0].name).toBe 'Test'
      expect(w.queue.queue[0].t).toBe 1
