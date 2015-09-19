{$, $$, View} = require 'atom-space-pen-views'
Profiles = require '../profiles/profiles'

module.exports =
  class ProfilePane extends View

    @content: ->
      @div class: 'panel-body padded', =>
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
        @div class: 'block hidden', outlet: 'stdout_profile_div', =>
          @label =>
            @div class: 'settings-name', 'Profile'
            @div =>
              @span class: 'inline-block text-subtle', 'Select Highlighting Profile'
          @select class: 'form-control', outlet: 'stdout_profile'
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
        @div class: 'block hidden', outlet: 'stderr_profile_div', =>
          @label =>
            @div class: 'settings-name', 'Profile'
            @div =>
              @span class: 'inline-block text-subtle', 'Select Highlighting Profile'
          @select class: 'form-control', outlet: 'stderr_profile'

    set: (command) ->
      @populateProfiles(@stdout_profile)
      @populateProfiles(@stderr_profile)

      if command?
        @stdout_highlights.find('.selected').removeClass('selected')
        @stderr_highlights.find('.selected').removeClass('selected')
        @stdout_highlights.find("\##{command.stdout.highlighting}").addClass('selected')
        @stderr_highlights.find("\##{command.stderr.highlighting}").addClass('selected')
        if command.stderr.highlighting is 'hc'
          @stderr_profile_div.removeClass('hidden')
          @selectProfile @stderr_profile, command.stderr.profile
        if command.stdout.highlighting is 'hc'
          @stdout_profile_div.removeClass('hidden')
          @selectProfile @stdout_profile, command.stdout.profile
      else
        @stdout_highlights.find('.selected').removeClass('selected')
        @stderr_highlights.find('.selected').removeClass('selected')
        @stdout_highlights.find('#nh').addClass('selected')
        @stderr_highlights.find('#nh').addClass('selected')
        @stderr_profile_div.addClass('hidden')
        @stdout_profile_div.addClass('hidden')

      @on 'click', '.btn-group .btn', ({currentTarget}) =>
        $(currentTarget.parentNode).find('.selected').removeClass('selected')
        currentTarget.classList.add 'selected'
        if currentTarget.id is 'hc'
          @["#{currentTarget.parentNode.id}_profile_div"].removeClass('hidden')
        else
          @["#{currentTarget.parentNode.id}_profile_div"].addClass('hidden')

    get: (command) ->
      command.stdout = {}
      command.stderr = {}
      command.stdout.highlighting = @stdout_highlights.find('.selected')[0].id
      command.stdout.profile = if command.stdout.highlighting is 'hc' then @stdout_profile.children()[@stdout_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue else undefined
      command.stderr.highlighting = @stderr_highlights.find('.selected')[0].id
      command.stderr.profile = if command.stderr.highlighting is 'hc' then @stderr_profile.children()[@stderr_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue else undefined
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
