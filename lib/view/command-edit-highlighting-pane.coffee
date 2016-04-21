{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
StreamPane = require './command-edit-stream-pane'
Environment = require '../environment/environment'

module.exports =
  class HighlightingPane extends View

    @content: ->
      @div class: 'panel-body', =>
        @div class: 'padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Environment'
              @div =>
                @span class: 'inline-block text-subtle', 'Configure Environment'
            @select class: 'form-control', outlet: 'environment'
          @div outlet: 'env'
        @div class: 'stream', outlet: 'stdout'
        @div class: 'stream', outlet: 'stderr'

    attached: ->
      @_stdout = new StreamPane
      @_stderr = new StreamPane
      @stdout.append @_stdout
      @stderr.append @_stderr
      @command = null
      @sourceFile = null
      @envPane = null
      @populateEnvironment()
      @environment.on 'change', @setEnvPane.bind(this), ({data, currentTarget}) ->
        value = currentTarget.children[currentTarget.selectedIndex].getAttribute('value')
        data(value)

    detached: ->
      @environment.off 'change'
      @_stdout.remove()
      @_stderr.remove()
      @_stdout = null
      @_stderr = null
      @command = null
      @sourceFile = null
      @envPane = null
      @stdout.empty()
      @stderr.empty()

    set: (@command, @sourceFile) ->
      @_stdout.set @command, 'stdout', @sourceFile
      @_stderr.set @command, 'stderr', @sourceFile
      if @command?
        @setEnvironment @command.environment.name
      else
        @setEnvironment 'child_process'

    populateEnvironment: ->
      createItem = (key, environment) ->
        $$ ->
          @option value: key, environment
      @environment.empty()
      for key, id in Object.keys Environment.modules
        @environment.append createItem(key, Environment.modules[key].name)
      @environment[0].selectedIndex = 0

    setEnvironment: (name) ->
      for option, id in @environment.children()
        if option.attributes.getNamedItem('value').nodeValue is name
          @environment[0].selectedIndex = id
          break
      @setEnvPane name

    setEnvPane: (value) ->
      @env.empty()
      unless Environment.activate value
        atom.notifications.addError 'Could not find environment module ' + value
        return
      Edit = Environment.modules[value].edit
      if Edit?
        edit = new Edit
        if edit.element?
          @env.append edit.element
        edit.set @command
        @envPane = edit
      else
        atom.notifications.addError 'Environment module has no edit pane ' + value

    get: (command) ->
      @envPane.get command
      @_stdout.get command, 'stdout'
      @_stderr.get command, 'stderr'
