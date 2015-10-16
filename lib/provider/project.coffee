CSON = require 'season'
Providers = require './provider'

{Emitter} = require 'atom'

path = require 'path'

module.exports =
  class ProjectConfig

    constructor: (@projectPath, @filePath, @viewed = false) ->
      @emitter = new Emitter if @viewed
      @providers = []
      data = CSON.readFileSync @filePath
      if data isnt null
        providers = data.providers
        commands = data.commands
      else
        providers = []
      save = false
      if commands? and not providers?
        save = true
        providers = []
        @migrateLocal(commands, providers)

      return unless providers?

      for p in providers
        continue unless Providers.activate(p.key) is true
        l = @providers.push {
          key: p.key
          config: p.config
          model: Providers.modules[p.key].model
          interface: new Providers.modules[p.key].model([@projectPath, @filePath], p.config, if @viewed then @save)
        }
        continue unless @viewed
        continue unless Providers.modules[p.key].view?
        provider = @providers[l - 1]
        provider.view = new Providers.modules[p.key].view(provider.interface)
      @save() if save
      null

    destroy: ->
      @emitter?.dispose()
      for provider in @providers
        provider.view?.destroy?()
        provider.interface.destroy?()
      @providers = null
      @global_data = null

    ############################################################################
    # Event functions
    ############################################################################

    onSave: (callback) ->
      @emitter.on 'save', callback

    ############################################################################
    # Getters
    ############################################################################

    getCommandById: (pid, id) ->
      new Promise((resolve, reject) =>
        if (c = @providers[pid]?.interface?.getCommandByIndex id) instanceof Promise
          c.then ((command) -> resolve(command)), reject
        else if c?
          resolve(c)
        else
          throw new Error("Could not get Command ##{id} from #{pid}")
      )

    getCommandByIndex: (id) ->
      new Promise((resolve, reject) =>
        @_providers = @providers.slice().reverse()
        @f = 0
        @_getCommandByIndex id, resolve, reject
      )

    getCommandNameObjects: ->
      new Promise((resolve, reject) =>
        @_providers = @providers.slice().reverse()
        @_return = []
        @_getCommandNameObjects resolve, reject
      )

    ############################################################################
    # Setters
    ############################################################################

    addProvider: (key) ->
      return false unless Providers.activate(key) is true
      l = @providers.push
        key: key
        config: {}
        model: Providers.modules[key].model

      @providers[l - 1].interface = new Providers.modules[key].model([@projectPath, @filePath], @providers[l - 1].config, @save)
      @providers[l - 1].view = new Providers.modules[key].view(@providers[l - 1].interface) if @viewed and Providers.modules[key].view?
      @save()
      return true

    removeProvider: (index) ->
      return false unless @providers.length > index
      @providers.splice(index, 1)[0]
      @save()
      return true

    moveProviderUp: (index) ->
      return false if (index is 0) or (index >= @providers.length)
      @providers.splice(index - 1, 0, @providers.splice(index, 1)[0])
      @save()
      return true

    moveProviderDown: (index) ->
      return false if (index >= @providers.length - 1)
      @providers.splice(index, 0, @providers.splice(index + 1, 1)[0])
      @save()
      return true

    ############################################################################
    # Private functions
    ############################################################################

    _getCommandByIndex: (id, resolve, reject) ->
      return reject(new Error("Command ##{id + 1} not found")) unless (p = @_providers.pop())?
      if (c = p.interface?.getCommandByIndex id - @f) instanceof Promise
        c.then resolve, =>
          if (c = p.interface?.getCommandCount()) instanceof Promise
            c.then ((count) =>
              @f = @f + count
              @_getCommandByIndex id, resolve, reject
            ), reject
          else
            @f = @f + (c ? 0)
            @_getCommandByIndex id, resolve, reject
      else if c?
        resolve(c)
      else
        if (c = p.interface?.getCommandCount()) instanceof Promise
          c.then ((count) =>
            @f = @f + count
            @_getCommandByIndex id, resolve, reject
          ), reject
        else
          @f = @f + (c ? 0)
          @_getCommandByIndex id, resolve, reject

    _getCommandNameObjects: (resolve, reject) ->
      return resolve(@_return) unless (p = @_providers.pop())?
      if (c = p.interface?.getCommandNames()) instanceof Promise
        c.then ((commands) =>
          _commands = ({name: command, singular: Providers.modules[p.key].singular, origin: p.key, id: i, pid: @providers.length - @_providers.length - 1} for command, i in commands)
          @_return = @_return.concat(_commands)
          @_getCommandNameObjects resolve, reject
        ), reject
        return
      else if c?
        @_return = @_return.concat ({name: command, singular: Providers.modules[p.key].singular, origin: p.key, id: i, pid: @providers.length - @_providers.length - 1} for command, i in c)
      @_getCommandNameObjects resolve, reject

    save: =>
      providers = []
      for provider in @providers
        providers.push
          key: provider.key
          config: provider.config
      CSON.writeFileSync @filePath, {providers}
      @emitter.emit 'save'

    @migrateCommand: (c) ->
      command = {}
      for key in ['project', 'name', 'command', 'wd']
        command[key] = c[key]
      if not c.version?
        c.version = 1
        if c.stdout.highlighting is 'hc'
          c.stdout.profile = 'gcc_clang'
        if c.stderr.highlighting is 'hc'
          c.stderr.profile = 'gcc_clang'
      if c.version is 1
        c.version = 2
        c.save_all = true
        c.close_success = false
      command.modifier = {}
      command.modifier.save_all = {} if c.save_all
      command.modifier.shell = command: 'bash -c' if c.shell
      command.modifier.wildcards = {} if c.wildcards
      command.stdout = c.stdout
      command.stderr = c.stderr
      command.output = {}
      command.output.console = {}
      command.output.console.close_success = c.close_success
      command.output.console.queue_in_buffer = true
      command.output.linter = {no_trace: false} if c.stderr.profile? or c.stdout.profile?
      command.version = 1
      return command

    migrateLocal: (commands, providers) ->
      providers.push key: 'bt', config: commands: []
      for command in commands
        providers[0].config.commands.push ProjectConfig.migrateCommand(command)
      atom.notifications?.addWarning "Imported #{commands.length} local command(s)"

    migrateGlobal: =>
      @addProvider 'bt'
      provider = @providers[@providers.length - 1].interface
      for command in @global_data[@projectPath].commands
        provider.addCommand(ProjectConfig.migrateCommand(command))

    hasGlobal: (callback) ->
      CSON.readFile path.join(path.dirname(atom.config.getUserConfigPath()), 'build-tools-cpp.projects'), (err, @global_data) =>
        return if err?
        callback() if @global_data[@projectPath]?
