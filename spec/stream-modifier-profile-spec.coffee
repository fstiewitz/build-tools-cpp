Modifier = require '../lib/stream-modifiers/profile'
Profiles = require '../lib/profiles/profiles'
XRegExp = require('xregexp').XRegExp

testProfileV1 =
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

testProfileV2 =
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

    in: (temp, perm) ->
      if (m = @regex.xexec temp.input)?
        m.type = 'error'
        @output.print m
        @output.lint m
        return 1
      return null

describe 'Stream Modifier - Highlighting Profile', ->
  mod = null
  config = profile: 'test'
  disp1 = null
  disp2 = null
  output = null

  beforeEach ->
    output =
      absolutePath: jasmine.createSpy('absolutePath').andCallFake (p) -> p
      createMessage: jasmine.createSpy('createMessage')
      replacePrevious: jasmine.createSpy('replacePrevious')
      print: jasmine.createSpy('print')
      pushLinterMessage: jasmine.createSpy('pushLinterMessage')
      createExtensionString: jasmine.createSpy('createExtensionString').andCallFake -> '(txt)'
      createRegex: jasmine.createSpy('createRegex').andCallFake (c, s) ->
        new XRegExp(c.replace(/\(\?extensions\)/g, s), 'xni')
      lint: jasmine.createSpy('lint')
    disp1 = Profiles.addProfile 'test1', testProfileV1, 1
    disp2 = Profiles.addProfile 'test2', testProfileV2, 2

  afterEach ->
    disp2.dispose()
    disp1.dispose()

  describe 'On constructor', ->

    beforeEach ->
      mod = new Modifier.modifier({profile: 'test1'}, null, output)

    it 'has set up the correct modify function', ->
      expect(mod.modify).toBe mod.modify1
