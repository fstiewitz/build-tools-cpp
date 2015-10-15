Profiles = require '../lib/profiles/profiles'
Outputs = require '../lib/output/output'
Providers = require '../lib/provider/provider'
Modifiers = require '../lib/modifier/modifier'
main = require '../lib/main'

testProfile =
  class TestProfile
    @profile_name: 'Test'

    scopes: ['text.plain']

    default_extensions: ['txt']

    regex_string: '
    ^(?<file> [\\S]+\\.(?extensions)):(?<row> [\\d]+):[ ](?<message> .+)$
    '

    file_string: '
    (?<file> [\\S]+\\.(?extensions)):(?<row> [\\d]+)
    '

    constructor: (@output) ->
      @extensions = @output.createExtensionString @scopes, @default_extensions
      @regex = @output.createRegex @regex_string, @extensions
      @regex_file = @output.createRegex @file_string, @extensions

    files: (line) ->
      start = 0
      out = []
      while (m = @regex_file.xexec line.substr(start))?
        start += m.index
        m.start = start
        m.end = start + m.file.length + m.row.length
        m.col = '0'
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = @regex.xexec line)?
        m.type = 'error'
        @output.print m
        @output.lint m

testModifier =
  name: 'Test modifier'
  preSplit: (command) ->
    return

testProvider =
  name: 'Test commands'
  model:
    class TestProvider

  view:
    class TestProviderView

testOutput =
  name: 'Test Output'
  description: 'Test Output'
  private: false

  edit:
    class TestPane
      set: (command) ->
      get: (command) ->

describe 'Linter Service', ->
  it 'has all necessary properties', ->
    provider = main.provideLinter()
    expect(provider.grammarScopes).toBeDefined()
    expect(provider.scope).toBeDefined()
    expect(provider.lintOnFly).toBeDefined()
    expect(provider.lint).toBeDefined()

describe 'Profile Service', ->
  [disp] = []

  beforeEach ->
    disp = main.consumeProfileModule key: 'test', profile: testProfile

  afterEach ->
    Profiles.reset()
    disp = null

  it 'returns a disposable', ->
    {Disposable} = require 'atom'
    expect(disp instanceof Disposable).toBeTruthy()

  it 'adds the profile with all necessary properties', ->
    expect(Profiles.profiles['test']).toBeDefined()
    expect(Profiles.profiles['test'].profile_name).toBe 'Test'
    expect(Profiles.profiles['test'].prototype.scopes).toEqual ['text.plain']

  describe 'when disposing the profile disposable', ->
    it 'removes the profile', ->
      disp.dispose()
      expect(Profiles.profiles['test']).toBeUndefined()

describe 'Output Service', ->
  [disp] = []

  beforeEach ->
    disp = main.consumeOutputModule key: 'test', mod: testOutput

  afterEach ->
    Outputs.reset()
    disp = null

  it 'returns a disposable', ->
    {Disposable} = require 'atom'
    expect(disp instanceof Disposable).toBeTruthy()

  it 'adds the module with all necessary properties', ->
    expect(Outputs.modules['test']).toBeDefined()
    expect(Outputs.modules['test'].name).toBe 'Test Output'

  describe 'when disposing the module disposable', ->
    it 'removes the module', ->
      disp.dispose()
      expect(Outputs.modules['test']).toBeUndefined()

describe 'Provider Service', ->
  [disp] = []

  beforeEach ->
    disp = main.consumeProviderModule key: 'test', mod: testProvider

  afterEach ->
    Providers.reset()
    disp = null

  it 'returns a disposable', ->
    {Disposable} = require 'atom'
    expect(disp instanceof Disposable).toBeTruthy()

  it 'adds the module with all necessary properties', ->
    expect(Providers.modules['test']).toBeDefined()
    expect(Providers.modules['test'].name).toBe 'Test commands'

  describe 'when disposing the module disposable', ->
    it 'removes the module', ->
      disp.dispose()
      expect(Providers.modules['test']).toBeUndefined()

describe 'Modifier Service', ->
  [disp] = []

  beforeEach ->
    disp = main.consumeModifierModule key: 'test', mod: testModifier

  afterEach ->
    Modifiers.reset()
    disp = null

  it 'returns a disposable', ->
    {Disposable} = require 'atom'
    expect(disp instanceof Disposable).toBeTruthy()

  it 'adds the module with all necessary properties', ->
    expect(Modifiers.modules['test']).toBeDefined()
    expect(Modifiers.modules['test'].name).toBe 'Test modifier'

  describe 'when disposing the module disposable', ->
    it 'removes the module', ->
      disp.dispose()
      expect(Modifiers.modules['test']).toBeUndefined()
