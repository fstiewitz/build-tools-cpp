provider = require('../lib/main').provideLinter()
ll = require '../lib/linter-list'

describe 'Linter Service', ->
  it 'has all necessary properties', ->
    expect(provider.grammarScopes).toBeDefined()
    expect(provider.scope).toBeDefined()
    expect(provider.lintOnFly).toBeDefined()
    expect(provider.lint).toBeDefined()

  describe 'on ::lint', ->
    it 'parses the linter messages correctly and returns an array of errors', ->
      ll.messages = {
        'somefile': [
          {type: 'error', message: 'hello world', row: '12', col: '23'}
          {type: 'trace', message: 'hello world 2', row: '12'}
        ]
      }
      editor = {
        getPath: ->
          'somefile'
      }
      expect(provider.lint editor).toEqual [
        {type: 'error', text: 'hello world', filePath: 'somefile', range: [[11,0],[11,22]]}
        {type: 'trace', text: 'hello world 2', filePath: 'somefile', range: [[11,0],[11,9999]]}
      ]
