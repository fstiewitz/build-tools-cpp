parser = require '../lib/build-parser'
path = require 'path'

describe "build tools cpp parser", ->
  fixturePath = ''
  beforeEach ->
    fixturePath = path.join(jasmine.currentEnv_.currentSpec.specDirectory,"fixtures")

  describe "when getWD ", ->
    describe "has valid arguments", ->
      it "returns the absolute path", ->
        expect(parser.getWD fixturePath,".").toBe(path.join(atom.project.getPaths()[0],"."))

    describe "has invalid arguments", ->
      it "returns ''", ->
        expect(parser.getWD fixturePath,"I-dont-think-this-exists").toBe('')

  describe "hasDependencies: ", ->
    describe "when no 'important file' is detected", ->
      it "returns ''", ->
        expect(parser.hasDependencies(fixturePath,"command_should_not_exist",[])).toBe('')

    describe "when an 'important file' is detected ", ->
      describe "but not found", ->
        it "returns the filename", ->
          expect(parser.hasDependencies(path.join(fixturePath,"empty"),"make",[])).toBe(path.join(fixturePath,"empty","Makefile"))

      describe "and found", ->
        it "returns ''", ->
          expect(parser.hasDependencies(fixturePath,"make",[])).toBe('')

      describe "but overridden by an option ", ->
        describe "and found", ->
          it "returns ''", ->
            expect(parser.hasDependencies(fixturePath,"make",["-fMakefile"])).toBe('')
            expect(parser.hasDependencies(fixturePath,"make",["-f","Makefile"])).toBe('')

        describe "and not found", ->
          it "returns the filename", ->
            expect(parser.hasDependencies(path.join(fixturePath,"empty"),"make",["-fMakefile"])).toBe(path.join(fixturePath,"empty","Makefile"))
            expect(parser.hasDependencies(path.join(fixturePath,"empty"),"make",["-f","Makefile"])).toBe(path.join(fixturePath,"empty","Makefile"))

      describe "but overriden by an argument ", ->
        describe "and found", ->
          it "returns ''", ->
            expect(parser.hasDependencies(fixturePath,"cmake",["."])).toBe('')

        describe "and not found", ->
          it "returns the filename", ->
            expect(parser.hasDependencies(path.join(fixturePath,"empty"),"cmake",["."])).toBe(path.join(fixturePath,"empty","CMakeLists.txt"))

  describe "when extension of extInList ", ->
    describe "exists", ->
      it "returns true", ->
        expect(parser.extInList([".cpp",".c"],"filename.cpp")).toBe(true)

    describe "does not exist", ->
      it "returns false", ->
        expect(parser.extInList([".cpp",".c"],"filename.h")).toBe(false)

  describe "when getFileNames ", ->
    saveConf = ""
    beforeEach ->
      saveConf = atom.config.get("build-tools-cpp.SourceFileExtensions")
      atom.config.set("build-tools-cpp.SourceFileExtensions",[".cpp"])

    describe "detects a file without coordinates", ->
      it "correctly returns a result object", ->
        expectedResult = {
          filename: path.join(fixturePath,"filename.cpp")
          row: 0
          col: 1
          start: 5
          end: path.join(fixturePath,"filename.cpp").length + 4
        }
        result = parser.getFileNames("test " + path.join(fixturePath,"filename.cpp") + ":")
        expect(result[0]).toEqual(expectedResult)

        result = parser.getFileNames("test " + path.join(fixturePath,"filename.cpp") + ":bla")
        expect(result[0]).toEqual(expectedResult)

    describe "detects a file with a line number", ->
      it "correctly returns a result object", ->
        expectedResult = {
          filename: path.join(fixturePath,"filename.cpp")
          row: '10'
          col: 1
          start: 5
          end: path.join(fixturePath,"filename.cpp").length + 7
        }
        result = parser.getFileNames("test " + path.join(fixturePath,"filename.cpp") + ":10:")
        expect(result[0]).toEqual(expectedResult)

    describe "detects a file with coordinates", ->
      it "correctly returns a result object", ->
        expectedResult = {
          filename: path.join(fixturePath,"filename.cpp")
          row: '10'
          col: '20'
          start: 5
          end: path.join(fixturePath,"filename.cpp").length + 10
        }
        result = parser.getFileNames("test " + path.join(fixturePath,"filename.cpp") + ":10:20")
        expect(result[0]).toEqual(expectedResult)

    afterEach ->
      atom.config.set("build-tools-cpp.SourceFileExtensions",saveConf)

  describe "when parseGCC ", ->
    describe "receives a line without a status indicator", ->
      it "returns ''", ->
        expect(parser.parseGCC("In function bla():")).toBe('')

    describe "receives a line with a status indicator", ->
      it "returns the correct status", ->
        expect(parser.parseGCC("filename.cpp:10:20: error: bla")).toBe('error')
        expect(parser.parseGCC("filename.cpp:10:20: warning: bla")).toBe('warning')

    describe "receives a line in an error message", ->
      it "returns the status of the last line with status indicator", ->
        expect(parser.parseGCC("filename.cpp:10:20: error: bla")).toBe('error')
        expect(parser.parseGCC('println("Hello\n")')).toBe('error')

    describe "receives a delimiter", ->
      it "returns the status of the previous lines and resets", ->
        expect(parser.parseGCC("filename.cpp:10:20: error: bla")).toBe('error')
        expect(parser.parseGCC('println("Hello\n")')).toBe('error')
        expect(parser.parseGCC('    ^    ')).toBe('error')
        expect(parser.parseGCC('In function bla():')).toBe('')

  describe "when removeQuotes ", ->
    describe "receives a line with quotes", ->
      it "removes them", ->
        expect(parser.removeQuotes('"Hello World"')).toBe('Hello World')

    describe "receives a line with multiple quote signs", ->
      it "removes the quotes with higher priority ( '\"' )", ->
        expect(parser.removeQuotes('"Hello \'World\'"')).toBe("Hello 'World'")
