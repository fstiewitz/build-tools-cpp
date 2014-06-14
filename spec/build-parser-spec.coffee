{WorkspaceView} = require 'atom'

parser = require '../lib/build-parser.coffee'
path = require 'path'

describe "build tools cpp parser", ->
  fixturePath = ''
  beforeEach ->
    fixturePath = path.join(jasmine.currentEnv_.currentSpec.specDirectory,"fixtures")

  describe "when getWD ", ->
    describe "has valid arguments", ->
      it "returns the absolute path", ->
        expect(parser.getWD fixturePath,".").toBe(path.join(atom.project.getPath(),"."))

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
