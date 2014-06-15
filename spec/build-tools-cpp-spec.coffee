tools = require '../lib/build-tools-cpp'

describe "build tools cpp", ->
  describe "when calling split without quotes", ->
    it "correctly splits the line", ->
      expect(tools.split("Hello World")).toEqual(["Hello","World"])

  describe "when calling split with quotes", ->
    it "splits the line without splitting inside quotes", ->
      expect(tools.split("Hello 'foo bar' World")).toEqual(["Hello","'foo bar'","World"])

  describe "when quotes are nested", ->
    it "splits the line correctly", ->
      expect(tools.split("Hello 'foo \"bar\"' World")).toEqual(["Hello","'foo \"bar\"'","World"])

  describe "test getcommand syntax", ->
    it "Test 1: 'command'", ->
      cmd = tools.split("command")
      res = tools.getcommand(cmd)
      expect(res.cmd).toBe("command")

    it "Test 2: 'command arg1 arg2'", ->
      cmd = tools.split("command arg1 arg2")
      res = tools.getcommand(cmd)
      expect(res.cmd).toBe("command")
      expect(res.arg).toEqual(["arg1","arg2"])

    it "Test 3: '\"command\" arg1 arg2'", ->
      cmd = tools.split("\"command\" arg1 arg2")
      res = tools.getcommand(cmd)
      expect(res.cmd).toBe("command")
      expect(res.arg).toEqual(["arg1","arg2"])

    it "Test 4: 'ENVVAR1=foo \"command\" arg1 arg2'", ->
      cmd = tools.split('ENVVAR1=foo "command" arg1 arg2')
      res = tools.getcommand(cmd)
      expect(res.env["ENVVAR1"]).toBe("foo")
      expect(res.cmd).toBe("command")
      expect(res.arg).toEqual(["arg1","arg2"])

    it "Test 5: 'ENVVAR1=foo ENVVAR2=\"bar bar\" \"command\" arg1 \"arg2\"'", ->
      cmd = tools.split('ENVVAR1=foo ENVVAR2="bar bar" "command" arg1 "arg2"')
      res = tools.getcommand(cmd)
      expect(res.env["ENVVAR1"]).toBe("foo")
      expect(res.env["ENVVAR2"]).toBe("bar bar")
      expect(res.cmd).toBe("command")
      expect(res.arg).toEqual(["arg1","arg2"])
