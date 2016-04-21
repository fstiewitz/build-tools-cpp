Edit = require('../lib/environment/ptyw').edit

describe 'ptyw.js', ->
  edit = null

  beforeEach ->
    edit = new Edit

  describe 'on new command', ->

    beforeEach ->
      edit.set null

    it 'resets all values', ->
      expect(edit.streams[0].selectedIndex).toBe 0
      expect(edit.pty_rows.getModel().getText()).toBe ''
      expect(edit.pty_cols.getModel().getText()).toBe ''

  describe 'on edit command', ->
    command = null

    beforeEach ->
      command =
        environment:
          name: 'ptyw'
          config:
            stdoe: 'pty-stderr'
            rows: 25
            cols: 80
      edit.set command

    it 'sets all values', ->
      expect(edit.streams[0].selectedIndex).toBe 1
      expect(edit.pty_rows.getModel().getText()).toBe '25'
      expect(edit.pty_cols.getModel().getText()).toBe '80'

    describe 'on get with correct values', ->
      nc = null
      ret = null

      beforeEach ->
        nc = {}
        ret = edit.get nc

      it 'writes the correct values', ->
        expect(nc).toEqual
          environment:
            name: 'ptyw'
            config:
              stdoe: 'pty-stderr'
              rows: 25
              cols: 80

      it 'returns null', ->
        expect(ret).toBe null

    describe 'on get with wrong values', ->
      nc = null
      ret = null

      beforeEach ->
        nc = {}
        edit.pty_cols.getModel().setText('a')
        ret = edit.get nc

      it 'does not write any values', ->
        expect(nc).toEqual {}

      it 'returns an error message', ->
        expect(ret).toBe 'cols: a is not a number'
