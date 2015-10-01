{$, $$, View} = require 'atom-space-pen-views'

ConsoleView = null
consoleview = null

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

  deactivate: ->
    consoleview.destroy()
    consoleview = null
    ConsoleView = null

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

      getView: -> #Not part of API (Spec function)
        consoleview

      newQueue: (@queue) ->
        ConsoleView ?= require '../view/console'
        consoleview ?= new ConsoleView
        consoleview.setQueueCount @queue.queue.length
        consoleview.clear()

      newCommand: (@command) ->
        consoleview.setCommand @command
        consoleview.showBox()
        consoleview.setHeader("#{@command.name} of #{@command.project}")
        consoleview.unlock()
        @stdout.lines = []
        @stderr.lines = []

      stdout:

        lines: []

        in: ({input, files}) ->
          @lines.push consoleview.printLine(buildHTML(input, '', files))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          for {input, files}, index in lines
            _new = buildHTML(input.input, (input.highlighting ? input.type), files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      stderr:

        lines: []

        in: ({input, files}) ->
          @lines.push consoleview.printLine(buildHTML(input, '', files))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          _new = buildHTML(input.input, (input.highlighting ? input.type), files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          for {input, files}, index in lines
            _new = buildHTML(input.input, (input.highlighting ? input.type), files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      error: (message) ->
        consoleview.hideOutput()
        consoleview.setHeader("#{@command.name} of #{@command.project}: received #{message}")

      exitCommand: (code) ->
        if code is 0
          consoleview.setQueueLength @queue.queue.length
          consoleview.setHeader(
            "#{@command.name} of #{@command.project}: finished with exitcode #{code}"
          )
        else
          consoleview.setHeader(
            "#{@command.name} of #{@command.project}: " +
            "<span class='error'>finished with exitcode #{code}</span>"
          )

      exitQueue: (code) ->
        consoleview.lock()
        if code is -2
          consoleview.setHeader(
            "#{@command.name} of #{@command.project}: " +
            "<span class='error'>aborted by user or package</span>"
          )
          consoleview.setQueueLength @queue.queue.length
        if consoleview.progress.prop('max') is 1 and code isnt 0
          consoleview.setQueueLength 1
        consoleview.finishConsole code
