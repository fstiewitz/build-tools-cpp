Module = require '../lib/output/linter'
ll = require '../lib/linter-list'

describe 'Output Module - Linter', ->
  module = null

  beforeEach ->
    module = new Module.output
    ll.messages.push 1
    module.newQueue(queue: [1, 2, 3])

  it 'initializes the linter array', ->
    expect(ll.messages.length).toBe 0

  describe 'On stdout linter message', ->

    beforeEach ->
      module.stdout_linter('Test message')

    it 'adds the message', ->
      expect(ll.messages[0]).toBe 'Test message'

  describe 'On stderr linter message', ->

    beforeEach ->
      module.stderr_linter('Test message')

    it 'adds the message', ->
      expect(ll.messages[0]).toBe 'Test message'

  describe 'On exitQueue', ->

    beforeEach ->
      spyOn(atom.commands, 'dispatch')
      module.exitQueue 0

    it 'calls the linter package to reload', ->
      expect(atom.commands.dispatch.mostRecentCall.args[1]).toBe 'linter:lint'
