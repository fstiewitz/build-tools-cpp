{$$$,View,TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class EditCommandView extends View
  nameEditor: null
  commandEditor: null
  wdEditor: null

  @content: ->
    @div class: 'editcommandview', =>
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Command Name'
          @div =>
            @span class:'inline-block text-subtle', 'Name of command when using '
            @span class:'inline-block highlight', 'build-tools-cpp:show-commands'
        @subview 'command_name', new TextEditorView(mini:true)
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Command'
          @div =>
            @span class:'inline-block text-subtle', 'Command to execute '
        @subview 'command_text', new TextEditorView(mini:true)
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Working Directory'
          @div =>
            @span class:'inline-block text-subtle', 'Directory to execute command in'
        @subview 'working_directory', new TextEditorView(mini:true)
      @div class:'block', =>
        @input id:'command_in_shell', type:'checkbox'
        @label =>
          @div class:'settings-name', 'Execute in shell'
          @div =>
            @span class:'inline-block text-subtle', 'Execute the command in your OS\'s shell'
      @div class:'streams', =>
        @div class:'stream', id:'stdout', =>
          @div class:'small-header', 'stdout'
          @div class:'block', =>
            @input id:'mark_paths_stdout', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stdout', class:'btn-group btn-group-sm', outlet:'stdout_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'GCC/Clang-like highlighting'
        @div class:'stream', id:'stderr', =>
          @div class:'small-header', 'stderr'
          @div class:'block', =>
            @input id:'mark_paths_stderr', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stderr', class:'btn-group btn-group-sm', outlet:'stderr_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'GCC/Clang-like highlighting'

  initialize: (@callback) ->
    @disposables = new CompositeDisposable
    @nameEditor = @command_name.getModel()
    @commandEditor = @command_text.getModel()
    @wdEditor = @working_directory.getModel()

    @on 'click', '.btn', (e) =>
      if e.currentTarget.parentNode.id is 'stdout'
        @stdout_highlighting = e.currentTarget.id
        @stdout_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')
      else if e.currentTarget.parentNode.id is 'stderr'
        @stderr_highlighting = e.currentTarget.id
        @stderr_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')

    @disposables.add atom.commands.add @element, 'core:confirm': (event) =>
        @callback(@oldname, {
          name: @nameEditor.getText(),
          command: @commandEditor.getText(),
          wd: @wdEditor.getText(),
          shell: @find('#command_in_shell').prop('checked')
          stdout: {
            file: @find('#mark_paths_stdout').prop('checked')
            highlighting: @stdout_highlighting
          }
          stderr: {
            file: @find('#mark_paths_stderr').prop('checked')
            highlighting: @stderr_highlighting
          }
          })
        @hide()
        event.stopPropagation()

    @disposables.add atom.commands.add @element, 'core:cancel': (event) =>
        @hide()
        event.stopPropagation()

  destroy: ->
    @disposables.dispose()
    @detach()

  hide: ->
    @panel?.hide()

  show: (items) ->
    @nameEditor.setText("")
    @commandEditor.setText("")
    @wdEditor.setText("")

    @find('#command_in_shell').prop('checked', false)
    @find('#mark_paths_stdout').prop('checked', true)
    @find('#mark_paths_stderr').prop('checked', true)

    @stdout_highlights.find('.selected').removeClass('selected')
    @stderr_highlights.find('.selected').removeClass('selected')
    @stdout_highlights.find('#nh').addClass('selected')
    @stderr_highlights.find('#nh').addClass('selected')

    @oldname = ""
    @stdout_highlighting = 'nh'
    @stderr_highlighting = 'nh'

    if items?
      @oldname = items.name
      @nameEditor.setText(items.name)
      @commandEditor.setText(items.command)
      @wdEditor.setText(items.wd)
      @find('#command_in_shell').prop('checked', items.shell)
      @find('#mark_paths_stdout').prop('checked', items.stdout.file)
      @find('#mark_paths_stderr').prop('checked', items.stderr.file)
      @stdout_highlights.find('.selected').removeClass('selected')
      @stderr_highlights.find('.selected').removeClass('selected')
      @stdout_highlights.find("\##{items.stdout.highlighting}").addClass('selected')
      @stderr_highlights.find("\##{items.stderr.highlighting}").addClass('selected')

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @command_name.focus();
