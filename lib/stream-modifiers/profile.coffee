module.exports =
  modifier:
    class ProfileModifier

      constructor: ({@config, @command, @output}) ->
        @profile = new Profiles.profiles[@config.profile]?(@output)
        if not @profile?
          atom.notifications?.addError "Could not find highlighting profile: #{@config.profile}"
          @modify = ->
          return
        @profile.clear?()
        @modify = this['modify' + Profiles.versions[@config.profile]]

      modify1: ({temp}) ->
        @profile.in temp.input
        return 1

      modify2: ({temp, perm}) ->
        return @profile.in temp, perm

      getFiles: (input) ->
        return @profile.files input.input
