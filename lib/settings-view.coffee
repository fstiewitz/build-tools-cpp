{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_p = require 'path'

ProjectPane = null
CommandPane = null

module.exports =
  class SettingsView extends View
    projectpane: null
    commandpane: null
    activepane: null

    show_all: false

    @content: ->
      @div class: 'settings pane-item', tabindex: -1, =>
        @div class: 'project-menu', =>
          @ul class: 'list-group', outlet: 'project_list'
          @div class: 'project-menu-options', =>
            @div class: 'block checkbox', =>
              @input id: 'show-all', type: 'checkbox'
              @label =>
                @div class: 'settings-name', 'Show all projects'
        @div class: 'panel padded', outlet: 'pane'

    initialize: ({@uri, @projects, @profiles}) ->
      ProjectPane ?= require './project-pane'
      CommandPane ?= require './command-pane'
      @projectpane = new ProjectPane(@projects,@profiles, (arg0,arg1,arg2,arg3) =>
        @showCommandPane()
        @commandpane.show arg0,arg1,arg2,arg3
      )
      @commandpane = new CommandPane(@projectpane.editccb, @hideCommandPane)
      @reload()
      @show_all = false
      @find('#show_all').prop('checked', false)
      @on 'change', '#show-all', (e) =>
        @show_all = $(e.currentTarget).prop('checked')
        @reload()
      @on 'click', '.checkbox label', (e) =>
        item = $(e.currentTarget.parentNode.children[0])
        item.prop('checked', not item.prop('checked'))
        @show_all = item.prop('checked')
        @reload()
      return

    destroy: ->
      @detach()
      @projectpane.destroy()
      @projectpane = null
      @commandpane.destroy()
      @commandpane = null
      @projects = null
      @profiles = null
      @activepane = null

    attached: ->
      @filechange = @projects?.onFileChange @reload

    detached: ->
      @filechange?.dispose()
      @filechange = null

    getURI: ->
      @uri

    getTitle: ->
      'Build Tools Settings'

    getIconName: ->
      'tools'

    showProjectPane: ->
      if @activepane isnt @projectpane
        @activepane?.detach()
        @pane.html @projectpane
        @activepane = @projectpane

    showCommandPane: ->
      if @activepane isnt @commandpane
        @activepane?.detach()
        @pane.html @commandpane
        @activepane = @commandpane

    hideCommandPane: =>
      @showProjectPane()

    updateProjects: ->
      if @show_all
        paths = @projects.getProjects()
      else
        paths = atom.project.getPaths()
      @project_list.empty()
      small_paths = @removeSharedPath paths
      for name, i in small_paths
        @addProject name, paths[i]
      @project_list.on 'click', '.project-item', (e) =>
        @setActiveProject e.currentTarget

    addProject: (name, path) ->
      item = $$ ->
        @li class: 'list-item project-item', =>
          @div class: 'icon icon-book', name
          @div class: 'text-subtle', path
      @project_list.append(item)
      @projects.addProject(path) if not @projects.getProject(path)?

    removeSharedPath: (paths) ->
      if paths.length is 1 then return paths
      path_elements = (e.split(_p.sep) for e in paths)
      item = ''
      finished = false

      while not finished
        item = path_elements[0][0]
        for p in path_elements
          if p[0] isnt item
            finished = true
        break if finished
        for p in path_elements
          p.splice(0,1)
      (e.join(_p.sep) for e in path_elements)

    setActiveProject: (e) ->
      name = e.children[0].innerHTML
      path = e.children[1].innerHTML
      @activeProject = @projects.getProject path
      @markAsActive e
      @showProjectPane()
      @projectpane.setContent @activeProject, name

    getElement: (path) ->
      for e in @project_list.children()
        if e.children[1].innerHTML is path
          return e

    reload: =>
      return unless @projects?
      @projectpane.hideModals()
      @showProjectPane()
      @updateProjects()
      if @activeProject?
        if @projects.getProject(@activeProject.path)? and (e = @getElement(@activeProject.path))?
          @setActiveProject e
        else
          @setActiveProject @project_list.children()[0]
      else
        @setActiveProject @project_list.children()[0]

    markAsActive: (e) ->
      @project_list.find('.active').removeClass('active')
      e.classList.add('active')
