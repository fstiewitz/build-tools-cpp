Modifiers = require '../stream-modifiers/modifiers'

{$$} = require 'atom-space-pen-views'

buildPane = (Element, name, command, config) ->
  if name?
    element = $$ ->
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', name
        if Element?
          @div class: 'panel-body padded'
  else
    element = $$ ->
      @div class: 'inset-panel', =>
        @div class: 'panel-body padded'
  if Element?
    el = new Element(command, config)
    element.find('.panel-body').append el.element
  element[0]

module.exports =
  class StreamInfoPane
    constructor: (command, data) ->
      @element = document.createElement 'div'
      keys = document.createElement 'div'
      values = document.createElement 'div'
      for {name, config} in data.pipeline
        continue unless Modifiers.activate name
        continue if Modifiers.modules[name].private
        mod = Modifiers.modules[name]
        @element.appendChild buildPane(mod.info, mod.name, command, config)
      @element.appendChild keys
      @element.appendChild values
