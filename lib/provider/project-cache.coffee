Provider = require './provider'

module.exports =
  class ProjectCache

    constructor: (@projectPath) ->
      @folderConfigs = {}
      @default = {}

    getConfig: (folderPath) ->
      @folderConfigs[folderPath]

    setToDefault: (folderPath) ->
      @folderConfigs[folderPath] = @getDefault()

    setDefault: (folderPath, def) ->
      @default = def
      @setToDefault folderPath

    getDefault: ->
      whitelist: @default.whitelist?.slice()
      blacklist: @default.blacklist?.slice() unless @default.whitelist?
      keybindings: [
        @default.keybindings?[0].slice()
        @default.keybindings?[1].slice()
        @default.keybindings?[2].slice()
      ]

    @getKeys: (config) ->
      return whitelist if (whitelist = config.whitelist)?
      keys = Object.keys(Provider.modules)
      return keys.filter((k) ->
        not (k in blacklist)
      ) if (blacklist = config.blacklist)?
      return keys
