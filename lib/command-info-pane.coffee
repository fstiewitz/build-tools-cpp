Profiles = require './profiles/profiles'

{View} = require 'atom-space-pen-views'

highlight_translation =
  'nh': 'No highlighting'
  'ha': 'Highlight all'
  'ht': 'Highlight tags'

module.exports =
  class CommandInfoPane extends View
    @content: ->
      @div class: 'command', =>
        @div class: 'top', =>
          @div id: 'info', class: 'align', =>
            @div class: 'icon-triangle-right expander'
            @div id: 'name', outlet: 'name'
          @div id: 'options', class: 'align', =>
            @div class: 'icon-pencil'
            @div class: 'icon-triangle-up'
            @div class: 'icon-triangle-down'
            @div class: 'icon-x'
        @div class: 'info hidden', =>
          @div id: 'general', =>
            @div =>
              @div class: 'text-padded', 'Command'
              @div class: 'text-padded', 'Working Directory'
              @div class: 'text-padded', 'Shell'
              @div class: 'text-padded', 'Wildcards'
              @div class: 'text-padded', 'Save All'
              @div class: 'text-padded', 'Close on success'
            @div class: 'values', =>
              @div class: 'text-highlight text-padded', outlet: 'command'
              @div class: 'text-highlight text-padded', outlet: 'wd'
              @div class: 'text-highlight text-padded', outlet: 'shell'
              @div class: 'text-highlight text-padded', outlet: 'wildcards'
              @div class: 'text-highlight text-padded', outlet: 'save_all'
              @div class: 'text-highlight text-padded', outlet: 'close_success'
          @div class: 'streams', =>
            @div id: 'stdout', class: 'stream', =>
              @div =>
                @div class: 'text-padded', 'Highlighting (stdout)'
                @div class: 'text-padded', 'Mark paths (stdout)'
                @div class: 'text-padded', 'Use Linter (stdout)'
              @div class: 'values', =>
                @div class: 'text-highlight text-padded', outlet: 'stdout_highlighting'
                @div class: 'text-highlight text-padded', outlet: 'stdout_file'
                @div class: 'text-highlight text-padded', outlet: 'stdout_lint'
            @div id: 'stderr', class: 'stream', =>
              @div =>
                @div class: 'text-padded', 'Highlighting (stderr)'
                @div class: 'text-padded', 'Mark paths (stderr)'
                @div class: 'text-padded', 'Use Linter (stderr)'
              @div class: 'values', =>
                @div class: 'text-highlight text-padded', outlet: 'stderr_highlighting'
                @div class: 'text-highlight text-padded', outlet: 'stderr_file'
                @div class: 'text-highlight text-padded', outlet: 'stderr_lint'

    initialize: ({name, command, wd, shell, wildcards, save_all, close_success, stdout, stderr}) ->
      @name.text name
      @command.text command
      @wd.text wd
      @shell.text shell.toString()
      @wildcards.text wildcards.toString()
      @save_all.text save_all.toString()
      @close_success.text close_success.toString()
      @stdout_highlighting.text if stdout.highlighting is 'hc' then String(Profiles.profiles[stdout.profile]?.profile_name) else highlight_translation[stdout.highlighting]
      @stdout_file.text if stdout.highlighting is 'hc' then stdout.file.toString() else 'Disabled'
      @stdout_lint.text if stdout.highlighting is 'hc' then stdout.lint.toString() else 'Disabled'
      @stderr_highlighting.text if stderr.highlighting is 'hc' then String(Profiles.profiles[stderr.profile]?.profile_name) else highlight_translation[stderr.highlighting]
      @stderr_file.text if stderr.highlighting is 'hc' then stderr.file.toString() else 'Disabled'
      @stderr_lint.text if stderr.highlighting is 'hc' then stderr.lint.toString() else 'Disabled'
