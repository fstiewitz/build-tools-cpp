{$, $$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_p = require 'path'

module.exports =
  class BuildToolsSettingsView extends ScrollView
    @content: ->
      @div class:'bt-settings pane-item native-key-bindings', tabindex:-1, =>
        @div class:'project-menu', =>
          @ul class:'list-group project-list', outlet:'project_list', =>
        @div class:'panel', outlet: 'project_content', =>
          @h1 "Test"
          @h2 "Test2"

    initialize: ({@uri}) ->
      @updateProjects(atom.project.getPaths())
      return

    destroy: ->
      @detach()

    getURI: ->
      @uri

    getTitle: ->
      'Build tools settings'

    getIconName: ->
      'tools'

    updateProjects: ->
      paths = atom.project.getPaths()
      @project_list.empty()
      paths = @removeSharedPath paths
      for path in paths
        @addProject path

    addProject: (path) ->
      @project_list.append("<li class='list-item project-item'><span class='icon icon-book'>#{path}</span></li>")

    removeSharedPath: (paths) ->
      if paths.length is 1 then return paths
      path_elements = (e.split(_p.sep) for e in paths)
      item = ""
      finished = false

      while not finished
        for e,i in path_elements
          if i is 0
            item = e.splice(0,1)[0]
          else
            if e[0] is item
              e.splice(0,1)
            else
              finished = true
              for j in [0..i-1]
                path_elements[j].splice(0,1,item)
              break
      (e.join(_p.sep) for e in path_elements)
