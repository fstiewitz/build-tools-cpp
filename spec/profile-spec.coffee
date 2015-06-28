Profiles = require '../lib/profiles/profiles'

describe 'Profiles', ->
  activationPromise = null

  beforeEach ->
    activationPromise = atom.packages.activatePackage('language-c')
    waitsForPromise -> activationPromise


  describe 'GCC/Clang', ->
    profile = null

    beforeEach ->
      profile = new Profiles.gcc_clang
      expect(profile).toBeDefined()

    afterEach ->
      profile.clear()

    it 'has a name', ->
      expect(profile.name).toBe 'GCC/Clang'

    it 'has scopes', ->
      expect(profile.scopes).toEqual ['source.c++', 'source.cpp', 'source.c']

    it 'has a regex string', ->
      expect(profile.regex_string).toBeDefined()

    it 'has a regex', ->
      expect(profile.regex).toBeDefined()

    describe 'on ::in with full match', ->
      string = 'something.cpp:12:23: fatal error: Hello World'
      match = null

      beforeEach ->
        match = profile.in string

      it 'returns a file name', ->
        expect(match.file).toBe 'something.cpp'

      it 'returns a line number', ->
        expect(match.row).toBe '12'

      it 'returns a column number', ->
        expect(match.col).toBe '23'

      it 'returns a type', ->
        expect(match.type).toBe 'error'

      it 'returns a message', ->
        expect(match.message).toBe 'Hello World'

    describe 'on ::in with file match', ->
      string = 'something.cpp:12'
      match = null

      beforeEach ->
        match = profile.in string

      it 'returns a file name', ->
        expect(match.file).toBe 'something.cpp'

      it 'returns a line number', ->
        expect(match.row).toBe '12'

      it 'returns no column number', ->
        expect(match.col).toBeUndefined()

      it 'returns no type', ->
        expect(match.type).toBeUndefined()

      it 'returns no message', ->
        expect(match.message).toBeUndefined()

    describe 'on ::in with multi line match', ->
      strings = [
        '/usr/include/stdlib.h:483:13: note: expected ‘void *’ but argument is of type ‘const void *’',
        ' extern void free (void *__ptr) __THROW;',
        '             ^',
      ]

      matches = []

      beforeEach ->
        for string in strings
          matches.push profile.in(string)

      it 'correctly sets warnings', ->
        expect(matches[0].file).toBe '/usr/include/stdlib.h'
        expect(matches[0].row).toBe '483'
        expect(matches[0].col).toBe '13'
        expect(matches[0].type).toBe 'warning'
        expect(matches[0].message).toBe 'expected ‘void *’ but argument is of type ‘const void *’'
        expect(matches[1].type).toBe 'warning'
        expect(matches[2].type).toBe 'warning'
