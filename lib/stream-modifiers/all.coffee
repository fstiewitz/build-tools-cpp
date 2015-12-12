module.exports =
  modifier:
    class AllModifier
      modify: ({temp}) ->
        temp.type = 'warning' if temp.type is ''
        return null
