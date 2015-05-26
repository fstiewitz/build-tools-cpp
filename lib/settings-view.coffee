{$, $$, ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_p = require 'path'

module.exports =
  class BuildToolsSettingsView extends ScrollView
    @content: ->
      @div class:'bt-settings pane-item native-key-bindings', tabindex:-1, =>
        @div class:'project-menu', =>
          @ul class:'list-group project-list', outlet:'project_list', =>
        @div class:'panel', =>
          @div class:'project-header', outlet: 'title'
          @div class:'section', =>
            @div class:'section-headerbar', =>
              @div class:'section-header', 'Commands'
              @div class:'inline-block btn btn-xs', 'Add command'
            @div class:'command-container', =>
              @div class:'key-info', =>
                @div class: 'key-desc text-subtle', =>
                  @div 'Make Command'
                  @div 'Configure Command'
                  @div 'Pre-Configure Command'
                @div class: 'key-press', =>
                  @div class:'text-highlight', 'Ctrl+L Ctrl+O'
                  @div class:'text-highlight', 'Ctrl+L Ctrl+I'
                  @div class:'text-highlight', 'Ctrl+L Ctrl+U'
              @div class:'command-menu', =>
                @ul class:'command-list', =>
                  @li 'Test'
          @div class:'section', =>
            @div class:'section-headerbar', =>
              @div class:'section-header', 'Dependencies'
              @div class:'inline-block btn btn-xs', 'Add dependency'
            @div class:'dependency-container', =>
              @ul class:'dependency-list', =>
                @li 'Test'

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
      @project_list.on 'click', '.project-item', (e) =>
        @setActiveProject e

    addProject: (path) ->
      item = $$ ->
        @li class:'list-item project-item', =>
          @div class:'icon icon-book project-name', path.split(_p.sep).reverse()[0]
          @div class:'text-subtle', path
      @project_list.append(item)

    removeSharedPath: (paths) ->
      if paths.length is 1 then return paths
      path_elements = (e.split(_p.sep) for e in paths)
      item = ''
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

    setActiveProject: (e) ->
      name = e.currentTarget.children[0].innerHTML
      @markAsActive e.currentTarget
      @setContent name

    setContent: (name) ->
      @title.html name

    markAsActive: (e) ->
      @project_list.find('.active').removeClass('active')
      e.classList.add('active')
