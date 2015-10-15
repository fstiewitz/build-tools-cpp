Module = require '../lib/output/buffer'

describe 'Output Module - Buffer', ->
  module = null

  beforeEach ->
    jasmine.attachToDOM(atom.views.getView atom.workspace)
    Module.activate()
    module = new Module.output

  afterEach ->
    module = null
    Module.deactivate()

  describe 'On false/false // false', ->
    buffer0 = null
    buffer1 = null

    beforeEach ->
      module.newQueue(queue: [
        {project: 'a', name: 'a', output: buffer: {recycle_buffer: false}}
        {project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}}
      ])
      module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: false}})
      module.stdout_in input: 'Hello World from a'
      waitsFor -> module.buffer isnt null
      runs ->
        buffer0 = module.buffer.getText()
        module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}})
        module.stdout_in input: 'Hello World from b'
        waitsFor -> module.buffer isnt null
        runs ->
          buffer1 = module.buffer.getText()

    it 'writes the first command to the first buffer', ->
      expect(buffer0).toBe 'Hello World from a\n'

    it 'writes the second command to the second buffer', ->
      expect(buffer1).toBe 'Hello World from b\n'

    describe 'On rerun', ->
      buffer0 = null
      buffer1 = null

      beforeEach ->
        module.newQueue(queue: [
          {project: 'a', name: 'a', output: buffer: {recycle_buffer: false}}
          {project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}}
        ])
        module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: false}})
        module.stdout_in input: 'Hello World from a'
        waitsFor -> module.buffer isnt null
        runs ->
          buffer0 = module.buffer.getText()
          module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}})
          module.stdout_in input: 'Hello World from b'
          waitsFor -> module.buffer isnt null
          runs ->
            buffer1 = module.buffer.getText()

      it 'writes the first command to the first buffer', ->
        expect(buffer0).toBe 'Hello World from a\n'

      it 'writes the second command to the second buffer', ->
        expect(buffer1).toBe 'Hello World from b\n'

  describe 'On false/false // true', ->
    buffer0 = null
    buffer1 = null

    beforeEach ->
      module.newQueue(queue: [
        {project: 'a', name: 'a', output: buffer: {recycle_buffer: true}}
        {project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}}
      ])
      module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: true}})
      module.stdout_in input: 'Hello World from a'
      waitsFor -> module.buffer?
      runs ->
        buffer0 = module.buffer.getText()
        module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}})
        module.stdout_in input: 'Hello World from b'
        waitsFor -> module.buffer?
        runs ->
          buffer1 = module.buffer.getText()

    it 'writes the first command to the first buffer', ->
      expect(buffer0).toBe 'Hello World from a\n'

    it 'writes the second command to the second buffer', ->
      expect(buffer1).toBe 'Hello World from b\n'

    it 'saves one buffer for re-cycling', ->
      expect(Module.getBuffers()['a']['a'].getText()).toBe 'Hello World from a\n'
      expect(Module.getBuffers()['b']).toBeUndefined()

    describe 'On rerun', ->
      buffer0 = null
      buffer1 = null

      beforeEach ->
        module.newQueue(queue: [
          {project: 'a', name: 'a', output: buffer: {recycle_buffer: true}}
          {project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}}
        ])
        module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: true}})
        module.stdout_in input: 'Hello World from a'
        waitsFor -> module.buffer?
        runs ->
          buffer0 = module.buffer
          module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: false, queue_in_buffer: false}})
          module.stdout_in input: 'Hello World from b'
          waitsFor -> module.buffer?
          runs ->
            buffer1 = module.buffer

      it 'writes the first command to the first buffer', ->
        expect(buffer0.getText()).toBe 'Hello World from a\n'

      it 'writes the second command to the second buffer', ->
        expect(buffer1.getText()).toBe 'Hello World from b\n'

      it 'uses the recycled buffer', ->
        expect(Module.getBuffers()['a']['a'].getText()).toBe 'Hello World from a\n'
        expect(Module.getBuffers()['b']).toBeUndefined()
        expect(Module.getBuffers()['a']['a']).toBe buffer0


  describe 'On true/true // true', ->
    buffer0 = null
    buffer1 = null

    beforeEach ->
      module.newQueue(queue: [
        {project: 'a', name: 'a', output: buffer: {recycle_buffer: true}}
        {project: 'b', name: 'a', output: buffer: {recycle_buffer: true, queue_in_buffer: true}}
      ])
      module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: true}})
      module.stdout_in input: 'Hello World from a'
      waitsFor -> module.buffer?
      runs ->
        buffer0 = module.buffer
        module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: true, queue_in_buffer: true}})
        module.stdout_in input: 'Hello World from b'
        waitsFor -> module.buffer?
        runs ->
          buffer1 = module.buffer

    it 'writes the first command to the first buffer', ->
      expect(buffer0.getText()).toBe 'Hello World from a\nHello World from b\n'

    it 'writes the second command to the first buffer', ->
      expect(buffer1.getText()).toBe 'Hello World from a\nHello World from b\n'

    it 'saves one buffer for re-cycling', ->
      expect(Module.getBuffers()['b']['a'].getText()).toBe 'Hello World from a\nHello World from b\n'
      expect(Module.getBuffers()['a']).toBeUndefined()
      expect(buffer0).toBe buffer1

    describe 'On rerun', ->
      buffer0 = null
      buffer1 = null

      beforeEach ->
        module.newQueue(queue: [
          {project: 'a', name: 'a', output: buffer: {recycle_buffer: true}}
          {project: 'b', name: 'a', output: buffer: {recycle_buffer: true, queue_in_buffer: true}}
        ])
        module.newCommand({project: 'a', name: 'a', output: buffer: {recycle_buffer: true}})
        module.stdout_in input: 'Hello World from a'
        waitsFor -> module.buffer?
        runs ->
          buffer0 = module.buffer
          module.newCommand({project: 'b', name: 'a', output: buffer: {recycle_buffer: true, queue_in_buffer: true}})
          module.stdout_in input: 'Hello World from b'
          waitsFor -> module.buffer?
          runs ->
            buffer1 = module.buffer

      it 'writes the first command to the first buffer', ->
        expect(buffer0.getText()).toBe 'Hello World from a\nHello World from b\n'

      it 'writes the second command to the first buffer', ->
        expect(buffer1.getText()).toBe 'Hello World from a\nHello World from b\n'

      it 'uses the shared buffer', ->
        expect(Module.getBuffers()['b']['a'].getText()).toBe 'Hello World from a\nHello World from b\n'
        expect(Module.getBuffers()['a']).toBeUndefined()
        expect(Module.getBuffers()['b']['a']).toBe buffer0
        expect(buffer0).toBe buffer1
