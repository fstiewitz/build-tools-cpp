{$$, View} = require 'atom-space-pen-views'

ConsoleView = null

module.exports =
  infoPane: (config) ->
    $$ ->
      @div class: 'module', =>
        @div =>
          @div class: 'text-padded', 'Close on success'
        @div class: 'values', =>
          @div class: 'text-highlight text-padded', config.close_success

  editPane:
    class ConsoleEdit extends View
      @content: ->
        @div class: 'panel-body padded hidden', =>
          @div class: 'block checkbox', =>
            @input id: 'close_success', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Close on success'
              @div =>
                @span class: 'inline-block text-subtle', 'Close console on success. Uses config value in package settings if enabled'

      initialize: (command) ->
        if command.output['console']?
          @find('#close_success').prop('checked', command.output['console'].close_success)
          @show()

      show: ->
        @removeClass 'hidden'

      hide: ->
        @addClass 'hidden'

      get: ->
        close_success: @find('#close_success').prop('checked')

  defaultConfig: (command) ->
    command.output['console'] =
      close_success: false

  output:
    class Console

      setInstance: (@instance) ->

      newQueue: (@queue) ->
        ConsoleView ?= require '../console'
        @view = new ConsoleView(@instance)
        @view.setQueueCount @queue.count
        @view.clear()

      newCommand: (@command) ->
        @view.createOutput @command
        @view.showBox()
        @view.setHeader("#{@command.name} of #{@command.project}")
        @view.unlock()

      stdout: (line, files) ->
        @view.stdout line, files

      stderr: (line, files) ->
        @view.stderr line, files

      error: (message) ->
        @view.hideOutput()
        @view.setHeader("#{@command.name} of #{@command.project}: received #{message}")
        @view.lock()

      exitCommand: (code) ->
        if code is 0
          @view.setQueueLength @queue.length
          @view.setHeader(
            "#{@command.name} of #{@command.project}: finished with exitcode #{code}"
          )
        else
          @view.setHeader(
            "#{@command.name} of #{@command.project}:" +
            "<span class='error'>finished with exitcode #{code}</span>"
          )

      exitQueue: (code) ->
        @view.finishConsole code
