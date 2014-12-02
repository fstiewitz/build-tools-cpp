linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
path = require 'path'
msgs = require './message-list.coffee'

class LinterBuildTools extends Linter
  @syntax: ['source.c++']

  cmd: ''
  regex: ''

  linterName: 'buildtoolslint'

  constructor: (editor) ->
    super(editor)

  lintFile: (filePath, callback) ->
    if (m=msgs.messages[path.basename(filePath)])?
      messages = []
      for item in m
        match = {
          message: item[4],
          line: item[2],
        }
        messages.push({
          line: item[2],
          level: item[3],
          message: item[4],
          linter: @linterName,
          range: @computeRange match
        })
      callback messages

module.exports = LinterBuildTools
