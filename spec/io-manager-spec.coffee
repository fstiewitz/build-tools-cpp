InputOutputManager = require '../lib/pipeline/io-manager'

path = require 'path'

command =
    name: ''
    command: ''
    wd: '.'
    stdout:
      pipeline: [
        {
          name: 'all'
        }
        {
          name: 'remansi'
        }
      ]
    stderr:
      pipeline: [
        {
          name: 'profile'
          config: {profile: 'modelsim'}
        }
      ]
    version: 2

describe 'Output Manager', ->
  manager = null
  output = null
  write_cb = null
  input = null
  input_cb = null

  beforeEach ->
    output =
      newCommand: jasmine.createSpy('newCommand')
      exitCommand: jasmine.createSpy('exitCommand')
      setInput: jasmine.createSpy('input').andCallFake (_input) -> input_cb = _input.write
      onInput: jasmine.createSpy('oninput')
      stdout_in: jasmine.createSpy('stdout_in')
      stdout_setType: jasmine.createSpy('stdout_setType')
      stdout_print: jasmine.createSpy('stdout_print')
      stderr_in: jasmine.createSpy('stderr_in')
      stderr_setType: jasmine.createSpy('stderr_setType')
      stderr_print: jasmine.createSpy('stderr_setType')
      stderr_linter: jasmine.createSpy('stderr_linter')
    input =
      write: jasmine.createSpy('write').andCallFake(write_cb = ((a, b, cb) -> cb()))
      end: jasmine.createSpy('end')
    command.project = atom.project.getPaths()[0]
    manager = new InputOutputManager(command, [output])
    manager.setInput input

  afterEach ->
    manager.destroy()

  it 'initalizes the output module', ->
    expect(output.newCommand).toHaveBeenCalledWith command

  it 'initalizes the input callbacks', ->
    expect(output.setInput).toHaveBeenCalled()

  describe 'On stdin output', ->

    beforeEach ->
      input_cb 'Test'

    it 'calls the input stream\'s write function', ->
      expect(input.write).toHaveBeenCalled()
      expect(input.write.mostRecentCall.args[0]).toBe 'Test'

    it 'calls the input callback', ->
      expect(output.onInput).toHaveBeenCalledWith 'Test'

  describe 'On stdout input', ->
    new_line = null
    mid_line = null
    end_line = null

    beforeEach ->
      new_line = jasmine.createSpy('new_line')
      mid_line = jasmine.createSpy('mid_line')
      end_line = jasmine.createSpy('end_line')
      manager.stdout.subscribers.on 'new', new_line
      manager.stdout.subscribers.on 'raw', mid_line
      manager.stdout.subscribers.on 'input', end_line

    describe 'On single line', ->
      beforeEach ->
        manager.stdout.in 'This is a single line\n'

      it 'calls "new"', ->
        expect(new_line.callCount).toBe 1

      it 'calls "raw"', ->
        expect(mid_line).toHaveBeenCalledWith 'This is a single line'

      it 'calls "input"', ->
        expect(end_line).toHaveBeenCalled()
        expect(end_line.mostRecentCall.args[0].input).toBe 'This is a single line'

    describe 'On multiple lines (2 full, last broken)', ->
      beforeEach ->
        manager.stdout.in 'First line\nSecond line\nThird'

      it 'calls "new" 3 times', ->
        expect(new_line.callCount).toBe 3

      it 'calls "raw" 3 times', ->
        expect(mid_line.callCount).toBe 3
        expect(mid_line.argsForCall).toEqual [['First line'], ['Second line'], ['Third']]

      it 'calls "input" 2 times', ->
        expect(end_line.callCount).toBe 2
        expect(end_line.argsForCall[0][0].input).toBe 'First line'
        expect(end_line.argsForCall[1][0].input).toBe 'Second line'

      it 'resets buffer', ->
        expect(manager.stdout.buffer).toBe 'Third'

      describe 'On adding to the third line', ->
        beforeEach ->
          manager.stdout.in ' line'

        it 'does not call "new"', ->
          expect(new_line.callCount).toBe 3

        it 'calls "raw"', ->
          expect(mid_line.mostRecentCall.args[0]).toBe ' line'

        it 'updates buffer', ->
          expect(manager.stdout.buffer).toBe 'Third line'

        describe 'On finishing the third line', ->
          beforeEach ->
            manager.stdout.in '\n'

          it 'calls "new"', ->
            expect(new_line.callCount).toBe 3

          it 'calls "input"', ->
            expect(end_line.callCount).toBe 3
            expect(end_line.mostRecentCall.args[0].input).toBe 'Third line'

    describe 'When encountering ANSI-Sequences', ->
      describe 'in one input string', ->
        beforeEach ->
          manager.stdout.in 'Hello\x1b[36mWorld\n'

        it 'calls "new"', ->
          expect(new_line.callCount).toBe 1

        it 'calls "raw" without the escape sequence', ->
          expect(mid_line.mostRecentCall.args[0]).toBe 'HelloWorld'

        it 'calls "input"', ->
          expect(end_line.mostRecentCall.args[0].input).toBe 'HelloWorld'

      describe 'in split input', ->
        beforeEach ->
          manager.stdout.in 'Hello\x1b['

        it 'calls "new"', ->
          expect(new_line).toHaveBeenCalled()

        it 'calls "raw"', ->
          expect(mid_line.mostRecentCall.args[0]).toBe 'Hello'

        describe 'second part', ->
          beforeEach ->
            manager.stdout.in '36'

          it 'does not call "new"', ->
            expect(new_line.callCount).toBe 1

          it 'does not call "raw"', ->
            expect(mid_line.callCount).toBe 1

          describe 'third part', ->
            beforeEach ->
              manager.stdout.in 'mWorld\n'

            it 'does not call "new"', ->
              expect(new_line.callCount).toBe 1

            it 'calls "raw"', ->
              expect(mid_line.mostRecentCall.args[0]).toBe 'World'

            it 'calls "input"', ->
              expect(end_line.mostRecentCall.args[0].input).toBe 'HelloWorld'

  describe 'On stderr input', ->
    new_line = null
    mid_line = null
    end_line = null

    beforeEach ->
      new_line = jasmine.createSpy('new_line')
      mid_line = jasmine.createSpy('mid_line')
      end_line = jasmine.createSpy('end_line')
      manager.stderr.subscribers.on 'new', new_line
      manager.stderr.subscribers.on 'raw', mid_line
      manager.stderr.subscribers.on 'input', end_line

    describe 'On single line', ->
      beforeEach ->
        manager.stderr.in 'This is a single line\n'

      it 'calls "new"', ->
        expect(new_line).toHaveBeenCalled()

      it 'calls "raw"', ->
        expect(mid_line).toHaveBeenCalledWith 'This is a single line'

      it 'calls "input"', ->
        expect(end_line).toHaveBeenCalled()
        expect(end_line.mostRecentCall.args[0].input).toBe 'This is a single line'

    describe 'On multiple lines (2 full, last broken)', ->
      beforeEach ->
        manager.stderr.in 'First line\nSecond line\nThird'

      it 'calls "new" 3 times', ->
        expect(new_line.callCount).toBe 3

      it 'calls "raw" 3 times', ->
        expect(mid_line.callCount).toBe 3
        expect(mid_line.argsForCall).toEqual [['First line'], ['Second line'], ['Third']]

      it 'calls "input" 2 times', ->
        expect(end_line.callCount).toBe 2
        expect(end_line.argsForCall[0][0].input).toBe 'First line'
        expect(end_line.argsForCall[1][0].input).toBe 'Second line'

      it 'resets buffer', ->
        expect(manager.stderr.buffer).toBe 'Third'

      describe 'On adding to the third line', ->
        beforeEach ->
          manager.stderr.in ' line'

        it 'calls "raw"', ->
          expect(mid_line.mostRecentCall.args[0]).toBe ' line'

        it 'updates buffer', ->
          expect(manager.stderr.buffer).toBe 'Third line'

        describe 'On finishing the third line', ->
          beforeEach ->
            manager.stderr.in '\n'

          it 'calls "new"', ->
            expect(new_line.callCount).toBe 3

          it 'calls "input"', ->
            expect(end_line.callCount).toBe 3
            expect(end_line.mostRecentCall.args[0].input).toBe 'Third line'

  describe 'On stdout input', ->
    it 'calls the correct functions', ->
      manager.stdout.in 'Hello World\n'
      expect(output.stdout_in).toHaveBeenCalledWith input: 'Hello World', files: []
      expect(output.stdout_print).not.toHaveBeenCalled()
      expect(output.stdout_setType).toHaveBeenCalledWith('warning')

  describe 'On stderr input', ->
    it 'calls the correct functions', ->
      input = '** Error: test.vhd(278): VHDL Compiler exiting'
      manager.stderr.in "#{input}\n"
      expect(output.stderr_in.mostRecentCall.args[0].input).toBe input
      match = {type: 'error', message: 'VHDL Compiler exiting', file: path.join(atom.project.getPaths()[0], 'test.vhd'), row: '278', input: input}
      test = output.stderr_print.mostRecentCall.args[0].input
      expect(test.input).toBe match.input
      expect(test.type).toBe match.type
      test = output.stderr_linter.mostRecentCall.args[0]
      expect(test.text).toBe match.message
      expect(test.type).toBe match.type
      expect(test.filePath).toBe match.file
      expect(test.range).toEqual [[277, 0], [277, 9999]]

  describe 'When command has finished', ->
    beforeEach ->
      manager.finish 0

    it 'sends the exit code to the module', ->
      expect(output.exitCommand).toHaveBeenCalledWith 0
