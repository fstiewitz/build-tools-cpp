{$, $$, View,TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class CommandView extends View
  nameEditor: null
  commandEditor: null
  wdEditor: null

  @content: ->
    @div class: 'commandview', =>
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Command Name'
          @div =>
            @span class:'inline-block text-subtle', 'Name of command when using '
            @span class:'inline-block highlight', 'build-tools-cpp:commands'
        @subview 'command_name', new TextEditorView(mini:true)
        @div id:'name-error-none' ,class:'error hidden', 'This field cannot be empty'
        @div id:'name-error-used' ,class:'error hidden', 'Name already used in this project'
      @div class:'block', =>
        @label =>
          @div class:'settings-header', =>
            @div class:'settings-name', 'Command'
            @div class:'wildcard-info icon-info', =>
              @div class:'content', =>
                @div class:'text-highlight bold', 'Wildcards'
                @div class:'info', =>
                  @div class:'col', =>
                    @div class:'text-subtle', 'Current File'
                    @div class:'text-subtle', 'Base Path'
                    @div class:'text-subtle', 'Folder (rel.)'
                    @div class:'text-subtle', 'File (no ext.)'
                  @div class:'col', =>
                    @div class:'text-highlight', '%f'
                    @div class:'text-highlight', '%b'
                    @div class:'text-highlight', '%d'
                    @div class:'text-highlight', '%e'
          @div =>
            @span class:'inline-block text-subtle', 'Command to execute '
        @subview 'command_text', new TextEditorView(mini:true)
        @div id:'command-error-none' ,class:'error hidden', 'This field cannot be empty'
      @div class:'block', =>
        @label =>
          @div class:'settings-header', =>
            @div class:'settings-name', 'Working Directory'
            @div class:'wildcard-info icon-info', =>
              @div class:'content', =>
                @div class:'text-highlight bold', 'Wildcards'
                @div class:'info', =>
                  @div class:'col', =>
                    @div class:'text-subtle', 'Current File'
                    @div class:'text-subtle', 'Base Path'
                    @div class:'text-subtle', 'Folder (rel.)'
                    @div class:'text-subtle', 'File (no ext.)'
                  @div class:'col', =>
                    @div class:'text-highlight', '%f'
                    @div class:'text-highlight', '%b'
                    @div class:'text-highlight', '%d'
                    @div class:'text-highlight', '%e'
          @div =>
            @span class:'inline-block text-subtle', 'Directory to execute command in'
        @subview 'working_directory', new TextEditorView(mini:true, placeholderText: '.')
      @div class:'block checkbox', =>
        @input id:'command_in_shell', type:'checkbox'
        @label =>
          @div class:'settings-name', 'Execute in shell'
          @div =>
            @span class:'inline-block text-subtle', 'Execute the command in your OS\'s shell. Change "Shell Command" in build-tools-cpp\'s settings if you are not using bash or use windows'
      @div class:'block checkbox', =>
        @input id:'wildcards', type:'checkbox'
        @label =>
          @div class:'settings-name', 'Replace Wildcards'
          @div =>
            @span class:'inline-block text-subtle', 'Enable if command or working directory contain wildcards'
      @div class:'streams', =>
        @div class:'stream', id:'stdout', =>
          @div class:'small-header', 'stdout'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stdout', class:'btn-group btn-group-sm', outlet:'stdout_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'Custom Profile'
          @div class:'block hidden', outlet:'stdout_profile_div', =>
            @label =>
              @div class:'settings-name', 'Profile'
              @div =>
                @span class:'inline-block text-subtle', 'Select Highlighting Profile'
            @select class:'form-control', outlet: 'stdout_profile'
          @div class:'block checkbox hidden', outlet:'stdout_mark', =>
            @input id:'mark_paths_stdout', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block checkbox hidden', outlet:'stdout_lint', =>
            @input id:'lint_stdout', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Lint errors/warnings'
              @div =>
                @span class:'inline-block text-subtle', 'Use Linter package to highlight errors in your code'
        @div class:'stream', id:'stderr', =>
          @div class:'small-header', 'stderr'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stderr', class:'btn-group btn-group-sm', outlet:'stderr_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'Custom Profile'
          @div class:'block hidden', outlet:'stderr_profile_div', =>
            @label =>
              @div class:'settings-name', 'Profile'
              @div =>
                @span class:'inline-block text-subtle', 'Select Highlighting Profile'
            @select class:'form-control', outlet: 'stderr_profile'
          @div class:'block checkbox hidden', outlet:'stderr_mark', =>
            @input id:'mark_paths_stderr', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block checkbox hidden', outlet:'stderr_lint', =>
            @input id:'lint_stderr', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Lint errors/warnings'
              @div =>
                @span class:'inline-block text-subtle', 'Use Linter package to highlight errors in your code'
        @div class:'buttons', =>
          @div class: 'btn btn-error icon icon-close inline-block-tight', 'Cancel'
          @div class: 'btn btn-primary icon icon-check inline-block-tight', 'Accept'

  initialize: (@callback) ->
    @disposables = new CompositeDisposable
    @nameEditor = @command_name.getModel()
    @commandEditor = @command_text.getModel()
    @wdEditor = @working_directory.getModel()

    @on 'click', '.btn-group .btn', (e) =>
      if e.currentTarget.parentNode.id is 'stdout'
        @stdout_highlighting = e.currentTarget.id
        @stdout_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')
        if @stdout_highlighting is 'hc'
          @stdout_profile_div.removeClass('hidden')
          @stdout_mark.removeClass('hidden')
          @stdout_lint.removeClass('hidden')
        else
          @stdout_profile_div.addClass('hidden')
          @stdout_mark.addClass('hidden')
          @stdout_lint.addClass('hidden')
      else if e.currentTarget.parentNode.id is 'stderr'
        @stderr_highlighting = e.currentTarget.id
        @stderr_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')
        if @stderr_highlighting is 'hc'
          @stderr_profile_div.removeClass('hidden')
          @stderr_mark.removeClass('hidden')
          @stderr_lint.removeClass('hidden')
        else
          @stderr_profile_div.addClass('hidden')
          @stderr_mark.addClass('hidden')
          @stderr_lint.addClass('hidden')

    @on 'click', '.buttons .icon-close', @cancel
    @on 'click', '.buttons .icon-check', @accept

    @disposables.add atom.commands.add @element,
      'core:confirm': @accept
      'core:cancel': @cancel

  destroy: ->
    @disposables.dispose()
    @detach()

  accept: (event) =>
    @find('.error').addClass('hidden')
    n = not @validName()
    c = not @validCommand()
    if n or c
      if n
        if @nameEditor.getText() is ''
          @find('#name-error-none').removeClass('hidden')
        else
          @find('#name-error-used').removeClass('hidden')
      if c
        @find('#command-error-none').removeClass('hidden')
    else
      @callback(@oldname,
        version: 1
        name: @nameEditor.getText()
        command: @commandEditor.getText()
        wd: if (d=@wdEditor.getText()) is '' then '.' else d
        shell: @find('#command_in_shell').prop('checked')
        wildcards: @find('#wildcards').prop('checked')
        stdout:
          file: @find('#mark_paths_stdout').prop('checked')
          highlighting: @stdout_highlighting
          profile: if @stdout_highlighting is 'hc' then $(@stdout_profile.children()[@stdout_profile[0].selectedIndex]).prop('value') else undefined
          lint: if @stdout_lint.hasClass('hidden') then false else @find('#lint_stdout').prop('checked')
        stderr:
          file: @find('#mark_paths_stderr').prop('checked')
          highlighting: @stderr_highlighting
          profile: if @stderr_highlighting is 'hc' then $(@stderr_profile.children()[@stderr_profile[0].selectedIndex]).prop('value') else undefined
          lint: if @stderr_lint.hasClass('hidden') then false else @find('#lint_stderr').prop('checked')
        )
      @hide()
    event.stopPropagation()

  validName: ->
    ((n=@nameEditor.getText()) isnt '') and ((n is @oldname) or (@project.getCommandIndex(n) is -1))

  validCommand: ->
    @commandEditor.getText() isnt ''

  cancel: (event) =>
    @hide()
    event.stopPropagation()

  hide: ->
    @panel?.hide()

  visible: ->
    if @panel?
      return @panel.isVisible()
    else
      return false

  show: (@oldname, items, @project, @profiles) ->
    @nameEditor.setText("")
    @commandEditor.setText("")
    @wdEditor.setText("")

    @find('#command_in_shell').prop('checked', false)
    @find('#wildcards').prop('checked', false)
    @find('#mark_paths_stdout').prop('checked', true)
    @find('#mark_paths_stderr').prop('checked', true)
    @find('#lint_stdout').prop('checked', false)
    @find('#lint_stderr').prop('checked', false)
    @stdout_profile_div.addClass('hidden')
    @stdout_mark.addClass('hidden')
    @stdout_lint.addClass('hidden')
    @stderr_profile_div.addClass('hidden')
    @stderr_mark.addClass('hidden')
    @stderr_lint.addClass('hidden')

    @stdout_highlights.find('.selected').removeClass('selected')
    @stderr_highlights.find('.selected').removeClass('selected')
    @stdout_highlights.find('#nh').addClass('selected')
    @stderr_highlights.find('#nh').addClass('selected')

    @stdout_highlighting = 'nh'
    @stderr_highlighting = 'nh'

    @populateProfiles @stdout_profile
    @populateProfiles @stderr_profile

    if items?
      @nameEditor.setText(items.name)
      @commandEditor.setText(items.command)
      @wdEditor.setText(items.wd)
      @find('#command_in_shell').prop('checked', items.shell)
      @find('#wildcards').prop('checked', items.wildcards)
      @find('#mark_paths_stdout').prop('checked', items.stdout.file)
      @find('#mark_paths_stderr').prop('checked', items.stderr.file)
      @stdout_highlights.find('.selected').removeClass('selected')
      @stderr_highlights.find('.selected').removeClass('selected')
      @stdout_highlights.find("\##{items.stdout.highlighting}").addClass('selected')
      @stderr_highlights.find("\##{items.stderr.highlighting}").addClass('selected')
      @stdout_highlighting = items.stdout.highlighting
      @stderr_highlighting = items.stderr.highlighting
      @stdout_lint.find('#lint_stdout').prop('checked', items.stdout.lint)
      @stderr_lint.find('#lint_stderr').prop('checked', items.stderr.lint)
      if @stderr_highlighting is 'hc'
        @stderr_profile_div.removeClass('hidden')
        @stderr_mark.removeClass('hidden')
        @stderr_lint.removeClass('hidden')
        @selectProfile @stderr_profile, items.stderr.profile
      if @stdout_highlighting is 'hc'
        @stdout_profile_div.removeClass('hidden')
        @stdout_mark.removeClass('hidden')
        @stdout_lint.removeClass('hidden')
        @selectProfile @stdout_profile, items.stderr.profile

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @command_name.focus()

  populateProfiles: (select) ->
    createitem = (key, profile) ->
      $$ ->
        @option value: key, profile
    select.empty()
    gcc_index = 0
    for key, id in Object.keys @profiles
      select.append createitem(key, @profiles[key].profile_name)
      gcc_index = id if key is 'gcc_clang'
    select[0].selectedIndex = gcc_index

  selectProfile: (select, profile) ->
    for option, id in select.children()
      if $(option).prop('value') is profile
        select[0].selectedIndex = id
        break
