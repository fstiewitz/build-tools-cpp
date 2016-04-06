module.exports =

  name: 'Highlight All'

  edit:
    class AllSaver
      get: (command, stream) ->
        command[stream].pipeline.push name: 'all'
        return null

  modifier:
    class AllModifier
      modify: ({temp}) ->
        temp.type = 'warning' unless temp.type? and temp.type isnt ''
        return null
