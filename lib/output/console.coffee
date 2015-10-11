{$, $$, View} = require 'atom-space-pen-views'

Console = null
consolemodel = null
consoleview = null
consolepanel = null

CompositeDisposable = null

buildHTML = (message, status, filenames) ->
  $$ ->
    status = '' if not status?
    status = 'info' if status is 'note'
    @div class: "bold text-#{status}", =>
      if filenames? and filenames.length isnt 0
        prev = -1
        for {file, row, col, start, end} in filenames
          @span message.substr(prev + 1, start - (prev + 1))
          @span class: "filelink highlight-#{status}", name: file, row: row, col: col, message.substr(start, end - start + 1)
          prev = end
        @span message.substr(prev + 1) if prev isnt message.length - 1
      else
        @span if message is '' then ' ' else message

module.exports =

  activate: ->
    Console = require '../console/console'
    ConsoleView = require '../console/console-element'
    consolemodel = new Console
    consoleview = new ConsoleView(consolemodel)
    consolepanel = atom.workspace.addBottomPanel(item: consoleview, visible: false)
    consoleview.show = -> consolepanel.show()
    consoleview.hide = -> consolepanel.hide()

    {CompositeDisposable} = require 'atom'
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add 'atom-workspace',
      'build-tools:toggle': ->
        if consolepanel.isVisible()
          consolepanel.hide()
        else
          consolepanel.show()
    @disposables.add atom.keymaps.add 'build-tools:console', 'atom-workspace': 'ctrl-l ctrl-s': 'build-tools:toggle'

  deactivate: ->
    consolepanel.destroy()
    consolemodel.destroy()
    @disposables.dispose()
    @disposables = null
    consolepanel = null
    consoleview = null
    consolemodel = null
    ConsoleView = null
    Console = null

  name: 'Console'
  description: 'Display command output in console pane'
  private: false

  edit:
    class ConsolePane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block checkbox', =>
            @input id: 'close_success', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Close on success'
              @div =>
                @span class: 'inline-block text-subtle', 'Close console on success. Uses config value in package settings if enabled'

      set: (command) ->
        if command?.output?.console?
          @find('#close_success').prop('checked', command.output.console.close_success)
        else
          @find('#close_success').prop('checked', if atom.config.get('build-tools.CloseOnSuccess') is -1 then false else true)

      get: (command) ->
        command.output.console ?= {}
        command.output.console.close_success = @find('#close_success').prop('checked')
        return null

  info:
    class ConsoleInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class: 'text-padded'>Close on success:</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.console.close_success)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Console

      newQueue: (@queue) ->
        @stdout._this = @stderr._this = this

      newCommand: (@command) ->
        @tab = consolemodel.getTab @command
        @tab.clear()
        @tab.unlock()
        @tab.setRunning()
        @tab.focus()
        @stdout.lines = []
        @stderr.lines = []

      stdout:

        lines: []

        in: ({input, files}) ->
          @lines.push(@_this.tab.printLine(buildHTML(input, '', files)))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          return unless last?
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          return unless @lines[@lines.length - 1]?
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          return unless @lines[@lines.length - lines.length]?
          for {input, files}, index in lines
            _new = buildHTML(input.input, (input.highlighting ? input.type), files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      stderr:

        lines: []

        in: ({input, files}) ->
          @lines.push(@_this.tab.printLine(buildHTML(input, '', files)))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          return unless last?
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          return unless @lines[@lines.length - 1]?
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          return unless @lines[@lines.length - lines.length]?
          for {input, files}, index in lines
            _new = buildHTML(input.input, (input.highlighting ? input.type), files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      error: (message) ->
        @tab.setError(message)
        @tab.lock()
        @tab.finishConsole()

      exitCommand: (code) ->
        @tab.setFinished(code)
        @tab.lock()
        @tab.finishConsole()

      exitQueue: (code) ->
        if code is -2
          @tab.setCancelled()
          @tab.lock()
          @tab.finishConsole()
