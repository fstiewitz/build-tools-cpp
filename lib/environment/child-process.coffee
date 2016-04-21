{BufferedProcess} = require 'atom'

{View} = require 'atom-space-pen-views'

fs = require 'fs'

pstree = null

translate =
  'none': 'Disable all output streams'
  'no-stdout': 'Disable stdout'
  'no-stderr': 'Disable stderr'
  'stderr-in-stdout': 'Redirect stderr in stdout'
  'stdout-in-stderr': 'Redirect stdout in stderr'
  'both': 'Display all output streams'

module.exports =
  name: 'Child Process'

  info:
    class CPInfoPane
      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Output Streams:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = translate[command.environment.config.stdoe]
        @element.appendChild key
        @element.appendChild value

  edit:
    class CPEditPane extends View

      @content: ->
        @div class: 'panel-body', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Output Streams'
              @div =>
                @span class: 'inline-block text-subtle', 'Configure standard output/error stream'
            @select class: 'form-control', outlet: 'streams', =>
              @option value: 'none', 'Disable all streams'
              @option value: 'no-stdout', 'No stdout'
              @option value: 'no-stderr', 'No stderr'
              @option value: 'stderr-in-stdout', 'Redirect stderr in stdout'
              @option value: 'stdout-in-stderr', 'Redirect stdout in stderr'
              @option value: 'both', 'Display all streams'

      set: (command, sourceFile) ->
        if command?.environment.name is 'child_process'
          for option, id in @streams.children()
            if option.attributes.getNamedItem('value').nodeValue is command.environment.config.stdoe
              @streams[0].selectedIndex = id
              break
        else
          @streams[0].selectedIndex = 5

      get: (command) ->
        value = @streams.children()[@streams[0].selectedIndex].attributes.getNamedItem('value').nodeValue
        command.environment =
          name: 'child_process'
          config:
            stdoe: value
        return null

  mod:
    class ChildProcess
      constructor: (@command, manager, @config) ->
        @killed = false
        if atom.inSpecMode()
          @promise = new Promise((@resolve, @reject) =>
            @process =
              exit: (exitcode) =>
                return @resolve(exitcode) if @killed
                @killed = true
                manager.finish exitcode
                @resolve(exitcode)
              error: (error) =>
                manager.error error
                @reject(error)
              kill: =>
                @killed = true
                manager.finish null
                @resolve(null)
          )
          @sigterm = -> @process.kill()
        else
          @promise = new Promise((@resolve, @reject) =>
            cwd = @command.getWD()
            fs.exists cwd, (exists) =>
              return @spawn(manager, cwd) if exists
              error = new Error("Working Directory #{cwd} does not exist")
              @killed = true
              manager.error(error)
              @reject(error)
          )
        @promise.then(
          =>
            @destroy()
          =>
            @destroy()
        )

      spawn: (manager, cwd) ->
        {command, args, env} = @command
        @process = new BufferedProcess(
          command: command
          args: args
          options:
            cwd: cwd
            env: env
        )
        @process.process.on 'close', (exitcode, signal) =>
          return if @killed
          @killed = true
          manager.finish({exitcode, signal})
          @resolve({exitcode, signal})
        if @config.stdoe isnt 'none'
          @process.process.stdout?.setEncoding 'utf8'
          @process.process.stderr?.setEncoding 'utf8'
          setupStream = (stream, into) ->
            stream.on 'data', (data) =>
              return unless @process?
              return if @killed
              into.in data
          if @config.stdoe is 'stderr-in-stdout'
            setupStream(@process.process.stdout, manager.stdout)
            setupStream(@process.process.stderr, manager.stdout)
          else if @config.stdoe is 'stdout-in-stderr'
            setupStream(@process.process.stdout, manager.stderr)
            setupStream(@process.process.stderr, manager.stderr)
          else if @config.stdoe is 'no-stdout'
            setupStream(@process.process.stderr, manager.stderr)
          else if @config.stdoe is 'no-stderr'
            setupStream(@process.process.stdout, manager.stdout)
          else if @config.stdoe is 'both'
            setupStream(@process.process.stdout, manager.stdout)
            setupStream(@process.process.stderr, manager.stderr)
        manager.setInput(@process.process.stdin)
        @process.onWillThrowError ({error, handle}) =>
          @killed = true
          manager.error(error)
          handle()
          @reject(error)

      getPromise: ->
        @promise

      isKilled: ->
        @killed

      sigterm: ->
        @sendSignal 'SIGINT'

      sigkill: ->
        @sendSignal 'SIGKILL'

      sendSignal: (signal) ->
        if process.platform is 'win32'
          @process?.kill(signal)
        else
          (pstree ? pstree = require 'ps-tree') @process.process.pid, (e, c) =>
            return if e?
            for child in c
              try
                process.kill child.PID, signal
              catch e
                console.log e
            try
              @process.process.kill signal
              @process.killed = true
            catch e
              console.log e

      destroy: ->
        @killed = true
        @promise = null
        @process = null
        @reject = (e) -> console.log "Received reject for finished process: #{JSON.stringify e}"
        @resolve = (e) -> console.log "Received resolve for finished process: #{JSON.stringify e}"
