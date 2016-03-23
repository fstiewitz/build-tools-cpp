Modifiers = require '../stream-modifiers/modifiers'

module.exports =
  class OutputPipelineRaw

    constructor: (@settings, @stream) ->
      @pipeline = []
      for {name, config} in @stream.pipeline
        if (c = Modifiers.modules[name])?
          if c.modifier.prototype.modify_raw?
            Modifiers.activate name
            @pipeline.push new c.modifier(config, @settings)
        else
          atom.notifications?.addError "Could not find raw stream modifier: #{name}"

    destroy: ->
      mod.destroy?() for mod in @pipeline
      @pipeline = null

    in: (_input) ->
      for mod in @pipeline
        _input = mod.modify_raw(_input)
      return _input
