Profiles = require '../profiles/profiles'
XRegExp = require('xregexp').XRegExp

module.exports =
  modifier:
    class ProfileModifier

      constructor: (@config, @command, @output) ->
        @profile = new Profiles.profiles[@config.profile]?(@output)
        if not @profile?
          atom.notifications?.addError "Could not find highlighting profile: #{@config.profile}"
          @modify = -> null
          return
        @profile.clear?()
        @modify = this['modify' + Profiles.versions[@config.profile]]

      modify1: ({temp}) ->
        @profile.in temp.input
        return 1

      modify2: ({temp, perm}) ->
        return @profile.in temp, perm

      getFiles: ({temp, perm}) ->
        return @profile.files temp.input.input
