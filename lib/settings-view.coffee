{$, $$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class BuildToolsSettingsView extends ScrollView
    @content: ->
      @div class:'pane-item native-key-bindings', tabindex:-1, =>
        @div class:'panel', =>
          @h1 "Test"

    initialize: ({@uri}) ->
      super
      return

    destroy: ->
      @detach()

    getURI: ->
      @uri

    getTitle: ->
      'Build tools settings'

    getIconName: ->
      'tools'
