{$, $$, View} = require 'atom-space-pen-views'

Console = null
consolemodel = null
consoleview = null
consolepanel = null

timeout = null

CompositeDisposable = null

AnsiParser = null

buildHTML = (message, status, filenames) ->
  $$ ->
    status = '' if not status?
    status = 'info' if status is 'note'
    @div class: "text-#{status}", =>
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
    AnsiParser = require './ansi-parser'
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

  provideConsole: ->
    consolemodel

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
          @div class: 'block checkbox', =>
            @input id: 'all_in_one', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Execute Queue in one tab'
              @div =>
                @span class: 'inline-block text-subtle', 'Print output of all commands of the queue in one tab'
          @div class: 'block checkbox', =>
            @input id: 'colors', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Use ANSI Color Codes'
              @div =>
                @span class: 'inline-block text-subtle', 'Highlight console output using ANSI Color Codes'
          @div class: 'block checkbox', =>
            @input id: 'stdin', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Allow user input'
              @div =>
                @span class: 'inline-block text-subtle', 'Allow user to interact with the spawned process'

      set: (command) ->
        if command?.output?.console?
          @find('#close_success').prop('checked', command.output.console.close_success)
          @find('#all_in_one').prop('checked', command.output.console.queue_in_buffer ? true)
          @find('#colors').prop('checked', command.output.console.colors ? false)
          @find('#stdin').prop('checked', command.output.console.stdin ? false)
        else
          @find('#close_success').prop('checked', if atom.config.get('build-tools.CloseOnSuccess') is -1 then false else true)
          @find('#all_in_one').prop('checked', true)
          @find('#colors').prop('checked', false)
          @find('#stdin').prop('checked', false)

      get: (command) ->
        command.output.console ?= {}
        command.output.console.close_success = @find('#close_success').prop('checked')
        command.output.console.queue_in_buffer = @find('#all_in_one').prop('checked')
        command.output.console.colors = @find('#colors').prop('checked')
        command.output.console.stdin = @find('#stdin').prop('checked')
        return null

  info:
    class ConsoleInfoPane

      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        keys.innerHTML = '''
        <div class="text-padded">Close on success:</div>
        <div class="text-padded">Execute queue in one tab:</div>
        <div class="text-padded">ANSI Colors:</div>
        <div class="text-padded">User Input:</div>
        '''
        values = document.createElement 'div'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.console.close_success)
        values.appendChild value
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.console.queue_in_buffer)
        values.appendChild value
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.console.colors)
        values.appendChild value
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.output.console.stdin)
        values.appendChild value
        @element.appendChild keys
        @element.appendChild values

  output:
    class Console

      newQueue: (queue) ->
        @queue_in_buffer = queue.queue[queue.queue.length - 1].output.console?.queue_in_buffer
        if @queue_in_buffer
          @tab = consolemodel.getTab queue.queue[queue.queue.length - 1]
          @tab.clear()
          clearTimeout timeout

      newCommand: (@command) ->
        unless @queue_in_buffer
          @tab = consolemodel.getTab @command
          @tab.clear()
          clearTimeout timeout
        @tab.setRunning()
        @tab.focus()
        @stdout_lines = []
        @stderr_lines = []

      setInput: (input) ->
        if @command.output.console.stdin
          @tab.setInput input.write
          consoleview.input_container.removeClass 'hidden'
          consoleview.input.focus()
        else
          consoleview.input_container.addClass 'hidden'

      stdout_new: ->
        if @command.output.console.colors and (last = @stdout_lines[@stdout_lines.length - 1])?
          if last.innerText is ''
            last.innerText = ' '
            AnsiParser.copyAttributes(@stdout_lines, @stdout_lines.length - 1)
        @stdout_lines.push(@tab.newLine())

      stdout_raw: (input) ->
        if @command.output.console.colors
          AnsiParser.parseAnsi(input, @stdout_lines, @stdout_lines.length - 1)
        else
          @stdout_lines[@stdout_lines.length - 1].innerText += input
        @tab.scroll()

      stdout_in: ({input}) ->
        @stdout_lines[@stdout_lines.length - 1].innerText = ' ' if input is ''

      stdout_setType: (status) ->
        last = @stdout_lines[@stdout_lines.length - 1]
        return unless last?
        status = '' if not status?
        status = 'info' if status is 'note'
        $(last).prop('class', "bold text-#{status}")

      stdout_print: ({input, files}) ->
        return unless @stdout_lines[@stdout_lines.length - 1]?
        _new = buildHTML(input.input, (input.highlighting ? input.type), files)
        element = $(@stdout_lines[@stdout_lines.length - 1])
        element.prop('class', _new.prop('class'))
        element.html(_new.html())

      stdout_replacePrevious: (lines) ->
        return unless @stdout_lines[@stdout_lines.length - lines.length - 1]?
        for {input, files}, index in lines
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@stdout_lines[@stdout_lines.length - lines.length + index - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

      stderr_new: ->
        if @command.output.console.colors and (last = @stderr_lines[@stderr_lines.length - 1])?
          if last.innerText is ''
            last.innerText = ' '
            AnsiParser.copyAttributes(@stderr_lines, @stderr_lines.length - 1)
        @stderr_lines.push(@tab.newLine())

      stderr_raw: (input) ->
        if @command.output.console.colors
          AnsiParser.parseAnsi(input, @stderr_lines, @stderr_lines.length - 1)
        else
          @stderr_lines[@stderr_lines.length - 1].innerText += input
        @tab.scroll()

      stderr_in: ({input}) ->
        @stderr_lines[@stderr_lines.length - 1].innerText = ' ' if input is ''

      stderr_setType: (status) ->
        last = @stderr_lines[@stderr_lines.length - 1]
        return unless last?
        status = '' if not status?
        status = 'info' if status is 'note'
        $(last).prop('class', "bold text-#{status}")

      stderr_print: ({input, files}) ->
        return unless @stderr_lines[@stderr_lines.length - 1]?
        _new = buildHTML(input.input, (input.highlighting ? input.type), files)
        element = $(@stderr_lines[@stderr_lines.length - 1])
        element.prop('class', _new.prop('class'))
        element.html(_new.html())

      stderr_replacePrevious: (lines) ->
        return unless @stderr_lines[@stderr_lines.length - lines.length - 1]?
        for {input, files}, index in lines
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@stderr_lines[@stderr_lines.length - lines.length + index - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

      error: (message) ->
        @tab.setError(message)
        @tab.finishConsole()

      exitCommand: (status) ->
        @tab.setFinished(status)
        return if @queue_in_buffer
        @finish(status)

      exitQueue: (code) ->
        if code is -2
          @tab.setCancelled()
          @tab.finishConsole()
          consoleview.hideInput() if @tab.hasFocus()
          return
        return unless @queue_in_buffer
        @finish(code)

      finish: (status) ->
        @tab.finishConsole()
        consoleview.hideInput() if @tab.hasFocus()
        if @command.output['console'].close_success and status is 0
          t = atom.config.get('build-tools.CloseOnSuccess')
          if t < 1
            consolepanel.hide()
            @tab = null
            @command = null
          else
            clearTimeout timeout
            timeout = setTimeout( =>
              consolepanel.hide() if @tab.hasFocus()
              timeout = null
              @tab = null
              @command = null
            , t * 1000)
