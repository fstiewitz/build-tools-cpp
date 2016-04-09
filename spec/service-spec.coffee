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

describe 'Input Service', ->
  it 'has all necessary properties', ->
    obj = main.provideInput()
    expect(obj.Input).toBe require '../lib/provider/input'
    expect(obj.ProviderModules).toBe Providers
    expect(obj.ProfileModules).toBe Profiles
    expect(obj.OutputModules).toBe Outputs
    expect(obj.ModifierModules).toBe Modifiers

describe 'Profile Service', ->
  [disp] = []

  beforeEach ->
    disp = main.consumeProfileModuleV1 key: 'test', profile: testProfile

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
    testOutput.activate = jasmine.createSpy('activate')
    testOutput.deactivate = jasmine.createSpy('deactivate')
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

  describe 'when activating the module', ->

    beforeEach ->
      Outputs.activate('test')

    it 'calls activate', ->
      expect(testOutput.activate).toHaveBeenCalled()

    it 'sets the active flag', ->
      expect(testOutput.active).toBe true

    describe 'when deactivating the module', ->

      beforeEach ->
        Outputs.deactivate('test')

      it 'calls deactivate', ->
        expect(testOutput.deactivate).toHaveBeenCalled()

      it 'unsets the active flag', ->
        expect(testOutput.active).toBe null

  describe 'when disposing the module disposable', ->

    beforeEach ->
      testOutput.active = true
      disp.dispose()

    it 'removes the module', ->
      expect(Outputs.modules['test']).toBeUndefined()

    it 'calls deactivate', ->
      expect(testOutput.deactivate).toHaveBeenCalled()

describe 'Modifier Service', ->
  [disp] = []

  beforeEach ->
    testModifier.activate = jasmine.createSpy('activate')
    testModifier.deactivate = jasmine.createSpy('deactivate')
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

  describe 'when activating the module', ->

    beforeEach ->
      Modifiers.activate('test')

    it 'calls activate', ->
      expect(testModifier.activate).toHaveBeenCalled()

    it 'sets the active flag', ->
      expect(testModifier.active).toBe true

    describe 'when deactivating the module', ->

      beforeEach ->
        Modifiers.deactivate('test')

      it 'calls deactivate', ->
        expect(testModifier.deactivate).toHaveBeenCalled()

      it 'unsets the active flag', ->
        expect(testModifier.active).toBe null

  describe 'when disposing the module disposable', ->

    beforeEach ->
      testModifier.active = true
      disp.dispose()

    it 'removes the module', ->
      expect(Modifiers.modules['test']).toBeUndefined()

    it 'calls deactivate', ->
      expect(testModifier.deactivate).toHaveBeenCalled()

describe 'Provider Service', ->
  [disp] = []

  beforeEach ->
    testProvider.activate = jasmine.createSpy('activate')
    testProvider.deactivate = jasmine.createSpy('deactivate')
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

  describe 'when activating the module', ->

    beforeEach ->
      Providers.activate('test')

    it 'calls activate', ->
      expect(testProvider.activate).toHaveBeenCalled()

    it 'sets the active flag', ->
      expect(testProvider.active).toBe true

    describe 'when deactivating the module', ->

      beforeEach ->
        Providers.deactivate('test')

      it 'calls deactivate', ->
        expect(testProvider.deactivate).toHaveBeenCalled()

      it 'unsets the active flag', ->
        expect(testProvider.active).toBe null

  describe 'when disposing the module disposable', ->

    beforeEach ->
      testProvider.active = true
      disp.dispose()

    it 'removes the module', ->
      expect(Providers.modules['test']).toBeUndefined()

    it 'calls deactivate', ->
      expect(testProvider.deactivate).toHaveBeenCalled()
