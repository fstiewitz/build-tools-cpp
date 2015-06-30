Profiles = require '../lib/profiles/profiles'

describe 'Profiles', ->

  beforeEach ->
    activationPromise = atom.packages.activatePackage('language-c')
    waitsForPromise -> activationPromise


  describe 'GCC/Clang', ->
    profile = null

    beforeEach ->
      profile = new Profiles.gcc_clang
      profile.clear()
      expect(profile).toBeDefined()

    afterEach ->
      profile.clear()

    it 'has a name', ->
      expect(profile.constructor.profile_name).toBe 'GCC/Clang'

    it 'has scopes', ->
      expect(profile.scopes).toEqual ['source.c++', 'source.cpp', 'source.c']

    it 'has a regex string', ->
      expect(profile.regex_string).toBeDefined()

    it 'has a regex', ->
      expect(profile.regex).toBeDefined()

    describe 'on ::in with multi line match', ->
      strings = [
        'In file included from test/src/def.h:32:0,',
        '                 from test/src/gen.h:31,',
        '                 from test/src/gen.c:27:',
        'should be traced too',
        '/usr/include/stdlib.h:483:13: note: expected ‘void *’ but argument is of type ‘const void *’',
        ' extern void free (void *__ptr) __THROW;',
        '             ^',
        'test/src/gen.c:126:6: error: implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]',
        '      print_element(input);',
        '      ^'
      ]

      expectations = [
        {file: 'test/src/def.h'       , row:'32' , col:'0'      , type:'trace'  , highlighting:'warning', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
        {file: 'test/src/gen.h'       , row:'31' , col:undefined, type:'trace'  , highlighting:'warning', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
        {file: 'test/src/gen.c'       , row:'27' , col:undefined, type:'trace'  , highlighting:'warning', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
        {                                                                       , highlighting:'warning', message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
        {file: '/usr/include/stdlib.h', row:'483', col:'13'     , type:'warning',                         message: 'expected ‘void *’ but argument is of type ‘const void *’'                          },
        {                                                         type:'warning'                                                                                                                       },
        {                                                         type:'warning'                                                                                                                       },
        {file: 'test/src/gen.c'       , row:'126', col:'6'      , type:'error'  ,                         message: 'implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]'},
        {                                                         type:'error'                                                                                                                         },
        {                                                         type:'error'                                                                                                                         }
      ]

      matches = []

      beforeEach ->
        for string in strings
          for match in profile.in(string)
            matches.push match if (not match.wait? or match.wait is false)

      it 'correctly sets warnings', ->
        expect(matches.length).toBe 10
        for match, index in matches
          expectation = expectations[index]
          for key in Object.keys(expectation)
            expect(match[key]).toBe expectation[key]

    describe 'on ::files', ->
      strings = [
        'In file included from test/src/def.h:32:0,',
        '                 from test/src/gen.h:31,',
        '                 from test/src/gen.c:27:',
        'should be traced too',
        '/usr/include/stdlib.h:483:13: note: expected ‘void *’ but argument is of type ‘const void *’',
        ' extern void free (void *__ptr) __THROW;',
        '             ^',
        'test/src/gen.c:126:6: error: implicit declaration of function ‘print_element’ [-Wimplicit-function-declaration]',
        '      print_element(input);',
        '      ^'
      ]

      expectations = [
        [{file: 'test/src/def.h'       , row:'32' , col:'0'      , start:22, end:40}],
        [{file: 'test/src/gen.h'       , row:'31' , col:undefined, start:22, end:38}],
        [{file: 'test/src/gen.c'       , row:'27' , col:undefined, start:22, end:38}],
        [],
        [{file: '/usr/include/stdlib.h', row:'483', col:'13'     , start:0 , end:27}],
        [],
        [],
        [{file: 'test/src/gen.c'       , row:'126', col:'6'      , start:0 , end:19}],
        [],
        []
      ]

      matches = []

      beforeEach ->
        for string in strings
          matches.push profile.files string

      it 'correctly sets file tags', ->
        expect(matches.length).toBe 10
        for match, index in matches
          expectation = expectations[index]
          for item, index in expectation
            for key in Object.keys(item)
              expect(match[index][key]).toBe item[key]
