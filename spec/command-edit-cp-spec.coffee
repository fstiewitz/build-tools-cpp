Edit = require('../lib/environment/child-process').edit

describe 'ChildProcess', ->
  edit = null

  beforeEach ->
    edit = new Edit

  describe 'on new command', ->

    beforeEach ->
      edit.set null

    it 'resets all values', ->
      expect(edit.streams[0].selectedIndex).toBe 5

  describe 'on edit command', ->
    command = null

    beforeEach ->
      command =
        environment:
          name: 'child_process'
          config:
            stdoe: 'no-stdout'
      edit.set command

    it 'sets all values', ->
      expect(edit.streams[0].selectedIndex).toBe 1

    describe 'on get with correct values', ->
      nc = null
      ret = null

      beforeEach ->
        nc = {}
        ret = edit.get nc

      it 'writes the correct values', ->
        expect(nc).toEqual
          environment:
            name: 'child_process'
            config:
              stdoe: 'no-stdout'

      it 'returns null', ->
        expect(ret).toBe null
