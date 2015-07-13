provider = require('../lib/main').provideLinter()
ll = require '../lib/linter-list'

describe 'Linter Service', ->
  it 'has all necessary properties', ->
    expect(provider.grammarScopes).toBeDefined()
    expect(provider.scope).toBeDefined()
    expect(provider.lintOnFly).toBeDefined()
    expect(provider.lint).toBeDefined()
