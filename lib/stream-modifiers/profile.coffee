{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
Profiles = require '../profiles/profiles'
XRegExp = require('xregexp').XRegExp

module.exports =

  name: 'Highlighting Profile'

  info:
    class ProfileInfoPane
      constructor: (command, config) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        key = document.createElement 'div'
        key.classList.add 'text-padded'
        key.innerText = 'Profile:'
        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = Profiles.profiles[config.profile]?.profile_name
        @element.appendChild key
        @element.appendChild value

  edit:
    class ProfileEditPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'block', =>
            @label =>
              @div class: 'settings-name', 'Profile'
              @div =>
                @span class: 'inline-block text-subtle', 'Select Highlighting Profile'
            @select class: 'form-control', outlet: 'profile'

      set: (command, config) ->
        @populateProfiles()
        if config?
          @selectProfile config.profile

      get: (command, stream) ->
        command[stream].pipeline.push {
          name: 'profile'
          config:
            profile: @profile.children()[@profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue
        }
        return null

      populateProfiles: ->
        createitem = (key, profile) ->
          $$ ->
            @option value: key, profile
        @profile.empty()
        gcc_index = 0
        for key, id in Object.keys Profiles.profiles
          @profile.append createitem(key, Profiles.profiles[key].profile_name)
          gcc_index = id if key is 'gcc_clang'
        @profile[0].selectedIndex = gcc_index

      selectProfile: (profile) ->
        for option, id in @profile.children()
          if option.attributes.getNamedItem('value').nodeValue is profile
            @profile[0].selectedIndex = id
            break

  modifier:
    class ProfileModifier

      constructor: (@config, @command, @output) ->
        @profile = new Profiles.profiles[@config.profile]?(@output)
        if not @profile?
          atom.notifications?.addError "Could not find highlighting profile: #{@config.profile}"
          return
        @profile.clear?()
        @modify = this['modify' + Profiles.versions[@config.profile]]

      modify: -> null

      modify1: ({temp}) ->
        @profile.in temp.input
        return 1

      modify2: ({temp, perm}) ->
        return @profile.in temp, perm

      getFiles: ({temp, perm}) ->
        if @profile?
          return @profile.files temp.input
        else
          return []
