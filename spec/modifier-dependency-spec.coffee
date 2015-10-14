Dependency = require '../lib/modifier/dependency'
Command = require '../lib/provider/command'

describe 'Queue Modifier - Dependencies', ->
  command = null
  queue = null

  beforeEach ->
    Dependency.activate(null, require '../lib/provider/project', null)
    command = new Command({
      project: atom.project.getPaths()[0]
      source: require('path').join(atom.project.getPaths()[0], '.build-tools.cson')
      name: 'Test 2'
      command: 'echo Hello World'
      modifier:
        dependency:
          abort: false
          list: [
            [1, 1, 'Bar 2']
            [0, 0, 'Test']
            [0, 2, 'Test 2']
          ]
      version: 1
    })
    queue =
      queue: [command]
    p = Dependency.in queue
    waitsForPromise -> p

  it 'returns the correct queue', ->
    expect(queue.queue[0].name).toBe 'Bar'
    expect(queue.queue[1].name).toBe 'Bar 2'
    expect(queue.queue[2].name).toBe 'Test'
    expect(queue.queue[3].name).toBe 'Test 2'
