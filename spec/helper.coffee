Output = require '../lib/pipeline/output-stream'

module.exports =
  profile: (name, command, stream, strings, expectations, files) ->
    describe command[stream].pipeline[0].config.profile, ->
      output = null

      beforeEach ->
        output = new Output(command, command[stream])
        expect(output).toBeDefined()
        expect(output.wholepipeline.pipeline.length).toBe 1

      it 'has a name', ->
        expect(output.wholepipeline.pipeline[0].profile.constructor.profile_name).toBe name

      it 'has scopes', ->
        expect(output.wholepipeline.pipeline[0].profile.scopes).toBeDefined()

      it 'has a `in` function', ->
        expect(output.wholepipeline.pipeline[0].profile.in).toBeDefined()

      it 'has a `files` function', ->
        expect(output.wholepipeline.pipeline[0].profile.files).toBeDefined()

      describe 'on ::in', ->
        matches = []

        beforeEach ->
          spyOn(output.wholepipeline, 'absolutePath').andCallFake (path) -> path
          spyOn(output.wholepipeline.pipeline[0].profile.output, 'lint').andCallFake (match) ->
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
            output.in string + '\n'

        it 'correctly sets warnings and errors', ->
          expect(matches.length).toBe expectations.length
          for match, index in matches
            expectation = expectations[index]
            for key in Object.keys(expectation)
              expect("Line[#{index}].#{key}: " + match[key]).toEqual "Line[#{index}].#{key}: " + expectation[key]

      return unless files?

      describe 'on ::files', ->
        matches = []

        beforeEach ->
          for string in strings
            matches.push output.wholepipeline.pipeline[0].profile.files string

        it 'correctly returns file descriptors', ->
          expect(matches.length).toBe files.length
          for match, index0 in matches
            expectation = files[index0]
            for item, index1 in expectation
              for key in Object.keys(item)
                expect("Line[#{index0}][#{index1}].#{key}: " + match[index1][key]).toBe "Line[#{index0}][#{index1}].#{key}: " + item[key]
