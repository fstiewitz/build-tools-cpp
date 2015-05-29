linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
path = require 'path'
msgs = require './linter-list.coffee'

module.exports =
  class LinterBuildTools extends Linter
    @syntax: ['source.c++', 'source.cpp', 'source.c']

    cmd: ''
    regex: ''

    linterName: 'Build Tools'

    constructor: (editor) ->
      super(editor)

    lintFile: (filePath, callback) ->
      if (m=msgs.messages[path.basename(filePath)])?
        messages = []
        for item in m
          match = {
            message: item[4],
            col: 0,
            line: item[2],
          }
          if (r = @computeRange match)?
            messages.push({
              line: item[2],
              level: item[3],
              message: item[4],
              linter: @linterName,
              range: r
            })
        callback messages
