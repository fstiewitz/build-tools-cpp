{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
Profiles = require '../profiles/profiles'

module.exports =
  class ProfilePane extends View

    @content: ->
      @div class: 'panel-body padded', =>
        @div class: 'block checkbox', =>
          @input id: 'pty', type: 'checkbox'
          @label =>
            @div class: 'settings-name', 'Use pty.js'
            @div =>
              @span class: 'inline-block text-subtle', 'Spawn processes in a pseudo-terminal. Can fix buffering issues with commands that require a pty. Disables stderr (all data arrives in stdout).'
        @div class: 'block', =>
          @label =>
            @div class: 'settings-name', 'Highlighting of stdout'
            @div =>
              @span class: 'inline-block text-subtle', 'How to highlight stdout'
        @div id: 'stdout', class: 'btn-group btn-group-sm', outlet: 'stdout_highlights', =>
          @button id: 'nh', class: 'btn selected', 'No highlighting'
          @button id: 'ha', class: 'btn', 'Highlight all'
          @button id: 'ht', class: 'btn', 'Lines with error tags'
          @button id: 'hc', class: 'btn', 'Custom Profile'
          @button id: 'hr', class: 'btn', 'Custom RegExp'
        @div class: 'block hidden', outlet: 'stdout_ansi_div', =>
          @div id: 'stdout_ansi', class: 'btn-group btn-group-sm', outlet: 'stdout_ansi', =>
            @button id: 'ignore', class: 'btn selected', 'Ignore ANSI Color Codes'
            @button id: 'remove', class: 'btn', 'Remove ANSI Color Codes'
            @button id: 'parse', class: 'btn', 'Parse ANSI Color Codes'
        @div class: 'block hidden', outlet: 'stdout_profile_div', =>
          @label =>
            @div class: 'settings-name', 'Profile'
            @div =>
              @span class: 'inline-block text-subtle', 'Select Highlighting Profile'
          @select class: 'form-control', outlet: 'stdout_profile'
        @div class: 'hidden', outlet: 'stdout_regex_div', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Regular Expression'
              @div =>
                @span class: 'inline-block text-subtle', 'Enter XRegExp string. The XRegExp object will use '
                @span class: 'inline-block highlight', 'xni'
                @span class: 'inline-block text-subtle', ' flags. Refer to the internet (including this package\'s wiki) for details.'
            @subview 'stdout_regex', new TextEditorView(mini: true)
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Hardcoded values'
              @div =>
                @span class: 'inline-block text-subtle', 'Enter CSON string with default properties. To highlight an error you need at least a '
                @span class: 'inline-block highlight', 'type'
                @span class: 'inline-block text-subtle', ' field. Linter messages require at least '
                @span class: 'inline-block highlight', 'type'
                @span class: 'inline-block text-subtle', ', '
                @span class: 'inline-block highlight', 'file'
                @span class: 'inline-block text-subtle', ', '
                @span class: 'inline-block highlight', 'row'
                @span class: 'inline-block text-subtle', ' and '
                @span class: 'inline-block highlight', 'message'
                @span class: 'inline-block text-subtle', ' fields.'
            @subview 'stdout_default', new TextEditorView(mini: true)
        @div outlet: 'stderr_div', class: 'hidden', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Highlighting of stderr'
              @div =>
                @span class: 'inline-block text-subtle', 'How to highlight stderr'
          @div id: 'stderr', class: 'btn-group btn-group-sm', outlet: 'stderr_highlights', =>
            @button id: 'nh', class: 'btn selected', 'No highlighting'
            @button id: 'ha', class: 'btn', 'Highlight all'
            @button id: 'ht', class: 'btn', 'Lines with error tags'
            @button id: 'hc', class: 'btn', 'Custom Profile'
            @button id: 'hr', class: 'btn', 'Custom RegExp'
          @div class: 'block hidden', outlet: 'stderr_ansi_div', =>
            @div id: 'stderr_ansi', class: 'btn-group btn-group-sm', outlet: 'stderr_ansi', =>
              @button id: 'ignore', class: 'btn selected', 'Ignore ANSI Color Codes'
              @button id: 'remove', class: 'btn', 'Remove ANSI Color Codes'
              @button id: 'parse', class: 'btn', 'Parse ANSI Color Codes'
          @div class: 'block hidden', outlet: 'stderr_profile_div', =>
            @label =>
              @div class: 'settings-name', 'Profile'
              @div =>
                @span class: 'inline-block text-subtle', 'Select Highlighting Profile'
            @select class: 'form-control', outlet: 'stderr_profile'
          @div class: 'block hidden', outlet: 'stderr_regex_div', =>
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'Regular Expression'
                @div =>
                  @span class: 'inline-block text-subtle', 'Enter XRegExp string. The XRegExp object will use '
                  @span class: 'inline-block highlight', 'xni'
                  @span class: 'inline-block text-subtle', ' flags. Refer to the internet (including this package\'s wiki) for details.'
              @subview 'stderr_regex', new TextEditorView(mini: true)
            @div class: 'block', =>
              @label =>
                @div class: 'settings-name', 'Hardcoded values'
                @div =>
                  @span class: 'inline-block text-subtle', 'Enter CSON string with default properties. To highlight an error you need at least a '
                  @span class: 'inline-block highlight', 'type'
                  @span class: 'inline-block text-subtle', ' field. Linter messages require at least '
                  @span class: 'inline-block highlight', 'type'
                  @span class: 'inline-block text-subtle', ', '
                  @span class: 'inline-block highlight', 'file'
                  @span class: 'inline-block text-subtle', ', '
                  @span class: 'inline-block highlight', 'row'
                  @span class: 'inline-block text-subtle', ' and '
                  @span class: 'inline-block highlight', 'message'
                  @span class: 'inline-block text-subtle', ' fields.'
              @subview 'stderr_default', new TextEditorView(mini: true)

    set: (command) ->
      @populateProfiles(@stdout_profile)
      @populateProfiles(@stderr_profile)

      if command?
        @stderr_div[0].className = if command.stdout.pty then 'hidden' else ''
        @find('#pty').prop('checked', command.stdout.pty ? false)
        @stdout_highlights.find('.selected').removeClass('selected')
        @stderr_highlights.find('.selected').removeClass('selected')
        @stdout_highlights.find("\##{command.stdout.highlighting}").addClass('selected')
        @stderr_highlights.find("\##{command.stderr.highlighting}").addClass('selected')
        if command.stderr.highlighting is 'hc'
          @stderr_profile_div.removeClass('hidden')
          @selectProfile @stderr_profile, command.stderr.profile
        else if command.stderr.highlighting is 'hr'
          @stderr_regex_div.removeClass('hidden')
          @stderr_regex.getModel().setText(command.stderr.regex)
          @stderr_default.getModel().setText(command.stderr.defaults)
        else if command.stderr.highlighting is 'nh'
          @stderr_ansi_div.removeClass('hidden')
          @stderr_ansi.find('.btn').removeClass('selected')
          @stderr_ansi.find("\##{command.stderr.ansi_option ? 'ignore'}").addClass('selected')
        if command.stdout.highlighting is 'hr'
          @stdout_regex_div.removeClass('hidden')
          @stdout_regex.getModel().setText(command.stdout.regex)
          @stdout_default.getModel().setText(command.stdout.defaults)
        else if command.stdout.highlighting is 'hc'
          @stdout_profile_div.removeClass('hidden')
          @selectProfile @stdout_profile, command.stdout.profile
        else if command.stdout.highlighting is 'nh'
          @stdout_ansi_div.removeClass('hidden')
          @stdout_ansi.find('.btn').removeClass('selected')
          @stdout_ansi.find("\##{command.stdout.ansi_option ? 'ignore'}").addClass('selected')
      else
        @find('#pty').prop('checked', false)
        @stderr_div.removeClass('hidden')
        @stdout_highlights.find('.selected').removeClass('selected')
        @stderr_highlights.find('.selected').removeClass('selected')
        @stdout_highlights.find('#nh').addClass('selected')
        @stderr_highlights.find('#nh').addClass('selected')
        @stdout_ansi_div.removeClass('hidden')
        @stderr_ansi_div.removeClass('hidden')
        @stdout_ansi.find('.selected').removeClass('selected')
        @stderr_ansi.find('.selected').removeClass('selected')
        @stdout_ansi.find('#ignore').addClass('selected')
        @stderr_ansi.find('#ignore').addClass('selected')
        @stderr_profile_div.addClass('hidden')
        @stdout_profile_div.addClass('hidden')
        @stderr_regex_div.addClass('hidden')
        @stdout_regex_div.addClass('hidden')
        @stdout_regex.getModel().setText('')
        @stdout_default.getModel().setText('')
        @stderr_regex.getModel().setText('')
        @stderr_default.getModel().setText('')

      @on 'click', '.btn-group .btn', ({currentTarget}) =>
        if (p_id = currentTarget.parentNode.id) is 'stdout' or p_id is 'stderr'
          $(currentTarget.parentNode).find('.selected').removeClass('selected')
          currentTarget.classList.add 'selected'
          if currentTarget.id is 'hc'
            @["#{currentTarget.parentNode.id}_ansi_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_profile_div"].removeClass('hidden')
            @["#{currentTarget.parentNode.id}_regex_div"].addClass('hidden')
          else if currentTarget.id is 'hr'
            @["#{currentTarget.parentNode.id}_ansi_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_profile_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_regex_div"].removeClass('hidden')
          else if currentTarget.id is 'nh'
            @["#{currentTarget.parentNode.id}_ansi_div"].removeClass('hidden')
            @["#{currentTarget.parentNode.id}_profile_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_regex_div"].addClass('hidden')
          else
            @["#{currentTarget.parentNode.id}_ansi_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_profile_div"].addClass('hidden')
            @["#{currentTarget.parentNode.id}_regex_div"].addClass('hidden')
        else
          $(currentTarget.parentNode).find('.selected').removeClass('selected')
          currentTarget.classList.add 'selected'

      @find('#pty')[0].onchange = =>
        if @find('#pty').prop('checked')
          @stderr_div.addClass 'hidden'
        else
          @stderr_div.removeClass 'hidden'


    get: (command) ->
      command.stdout = {}
      command.stderr = {}
      command.stdout.pty = @find('#pty').prop('checked')
      command.stdout.highlighting = @stdout_highlights.find('.selected')[0].id
      command.stdout.profile = if command.stdout.highlighting is 'hc' then @stdout_profile.children()[@stdout_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue else undefined
      if command.stdout.highlighting is 'hr'
        return 'Regular expression must not be empty' if @stdout_regex.getModel().getText() is ''
        command.stdout.regex = @stdout_regex.getModel().getText()
        command.stdout.defaults = @stdout_default.getModel().getText()
      else if command.stdout.highlighting is 'nh'
        command.stdout.ansi_option = @stdout_ansi.find('.selected')[0].id
      command.stderr.highlighting = @stderr_highlights.find('.selected')[0].id
      command.stderr.profile = if command.stderr.highlighting is 'hc' then @stderr_profile.children()[@stderr_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue else undefined
      if command.stderr.highlighting is 'hr'
        return 'Regular expression must not be empty' if @stderr_regex.getModel().getText() is ''
        command.stderr.regex = @stderr_regex.getModel().getText()
        command.stderr.defaults = @stderr_default.getModel().getText()
      else if command.stderr.highlighting is 'nh'
        command.stderr.ansi_option = @stderr_ansi.find('.selected')[0].id
      return null

    populateProfiles: (select) ->
      createitem = (key, profile) ->
        $$ ->
          @option value: key, profile
      select.empty()
      gcc_index = 0
      for key, id in Object.keys Profiles.profiles
        select.append createitem(key, Profiles.profiles[key].profile_name)
        gcc_index = id if key is 'gcc_clang'
      select[0].selectedIndex = gcc_index

    selectProfile: (select, profile) ->
      for option, id in select.children()
        if option.attributes.getNamedItem('value').nodeValue is profile
          select[0].selectedIndex = id
          break
