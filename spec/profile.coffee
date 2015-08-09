Output = require '../lib/output'
ll = require '../lib/linter-list'

module.exports =
  profile: (name, command, stream, packages, strings, expectations, files) ->
    describe command[stream].profile, ->
      output = null
      promises = null

      beforeEach ->
        promises = {} if not promises?
        for p in packages
          promises[p] = atom.packages.activatePackage(p)
          waitsForPromise -> promises[p]
        output = new Output(command, stream, (p) -> p)
        expect(output).toBeDefined()
        expect(output.profile).toBeDefined()

      it 'has a name', ->
        expect(output.profile.constructor.profile_name).toBe name

      it 'has scopes', ->
        expect(output.profile.scopes).toBeDefined()

      it 'has a `in` function', ->
        expect(output.profile.in).toBeDefined()

      it 'has a `clear` function', ->
        expect(output.profile.clear).toBeDefined()

      describe 'on ::in', ->
        matches = []

        beforeEach ->
          spyOn(output, 'absolutePath').andCallFake (path) -> path
          spyOn(output.profile, 'lint').andCallFake (match) ->
            if match? and match.file? and match.row? and match.type? and match.message?
              matches.push
                file: match.file
                row: match.row
                col: match.col
                type: match.type
                highlighting: match.highlighting
                message: match.message
                trace: match.trace

          for string in strings
            output.in string

        it 'correctly sets warnings and errors', ->
          expect(matches.length).toBe expectations.length
          for match, index in matches
            expectation = expectations[index]
            for key in Object.keys(expectation)
              expect(match[key]).toEqual expectation[key]

      return unless files?

      describe 'on ::files', ->
        matches = []

        beforeEach ->
          for string in strings
            matches.push output.profile.files string

        it 'correctly returns file descriptors', ->
          expect(matches.length).toBe files.length
          for match, index in matches
            expectation = files[index]
            for item, index in expectation
              for key in Object.keys(item)
                expect(match[index][key]).toBe item[key]
