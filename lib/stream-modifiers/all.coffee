module.exports =

  edit:
    class AllSaver
      get: (command, stream) ->
        stream.pipeline.push name: 'all'
        return null

  modifier:
    class AllModifier
      modify: ({temp}) ->
        temp.type = 'warning' if temp.type is ''
        return null
