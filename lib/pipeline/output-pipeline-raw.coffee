Modifiers = require '../stream-modifiers/modifiers'

module.exports =
  class OutputPipelineRaw

    constructor: (@settings, @stream) ->
      @buildPipeline(@stream.pipeline)

    destroy: ->
      mod.destroy?() for mod in @pipeline
      @pipeline = null

    buildPipeline: (blueprint) ->
      @pipeline = []
      for {name, config} in blueprint
        if (c = Modifiers.modules[name])?
          @pipeline.push new c.modifier(config, @settings) if c.modifier.prototype.modify_raw?
        else
          atom.notifications?.addError "Could not find raw stream modifier: #{name}"

    in: (_input) ->
      for mod in @pipeline
        _input = mod.modify_raw(_input)
      return _input
