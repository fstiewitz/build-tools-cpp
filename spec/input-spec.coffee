Input = require '../lib/provider/input'
path = require 'path'

describe 'Input', ->
  describe '::getFirstConfig', ->
    describe 'When config in current folder', ->
      file = null
      folder = null
      promise = null

      beforeEach ->
        promise = Input.getFirstConfig path.join(atom.project.getPaths()[0], 'root1', 'sub0')
        promise.then ({folderPath, filePath}) ->
          folder = folderPath
          file = filePath
        waitsForPromise -> promise

      it 'returns the correct file path', ->
        expect(folder).toBe path.join(atom.project.getPaths()[0], 'root1', 'sub0')
        expect(file).toBe path.join(atom.project.getPaths()[0], 'root1', 'sub0', '.build-tools.cson')

    describe 'When config not in current folder', ->
      file = null
      folder = null
      promise = null

      beforeEach ->
        promise = Input.getFirstConfig path.join(atom.project.getPaths()[0], 'root1', 'sub1')
        promise.then ({folderPath, filePath}) ->
          folder = folderPath
          file = filePath
        waitsForPromise -> promise

      it 'returns the correct file path', ->
        expect(folder).toBe atom.project.getPaths()[0]
        expect(file).toBe path.join(folder, '.build-tools.cson')
