{$, $$, ScrollView,TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_p = require 'path'
main = require './main.coffee'

highlight_translation= {
  "nh": "No highlighting",
  "ha": "Highlight all",
  "ht": "Highlight tags",
  "hc": "GCC/Clang highlighting"
}

module.exports =
  class SettingsView extends ScrollView
    CommandView: null
    commandview: null

    @content: ->
      @div class:'settings pane-item native-key-bindings', tabindex:-1, =>
        @div class:'project-menu', =>
          @ul class:'list-group', outlet:'project_list', =>
        @div class:'panel', =>
          @div class:'project-header', outlet: 'title'
          @div class:'section', =>
            @div =>
              @div class:'section-header', 'Commands'
              @div id:'add-command-button', class:'inline-block btn btn-xs', 'Add command'
              @div class:'inline-block btn btn-xs', 'Import command'
            @div class:'command-container', =>
              @div class:'key-info', =>
                @div class: 'key-desc text-subtle', =>
                  @span 'Make Command'
                  @span class:'text-highlight', 'Ctrl+L Ctrl+O'
                @div class: 'key-desc text-subtle', =>
                  @span 'Configure Command'
                  @span class:'text-highlight', 'Ctrl+L Ctrl+I'
                @div class: 'key-desc text-subtle', =>
                  @span 'Pre-Configure Command'
                  @span class:'text-highlight', 'Ctrl+L Ctrl+U'
              @div class:'command-menu', =>
                @div class:'command-list', outlet: 'command_list', =>
          @div class:'section', =>
            @div =>
              @div class:'section-header', 'Dependencies'
              @div class:'inline-block btn btn-xs', 'Add dependency'
              @div class:'inline-block btn btn-xs', 'Import dependency'
            @div outlet:'dependency_list', =>

    initialize: ({@uri}) ->
      super
      @CommandView=null
      @commandview=null
      @on 'click', '#add-command-button', (e) =>
        @CommandView ?= require './command-view'
        @commandview ?= new @CommandView(@editcb)
        @commandview.show()
      @reload()
      return

    destroy: ->
      @detach()

    attached: ->
      @filechange = main.projects.onFileChange @reload

    detached: ->
      @filechange?.dispose()

    getURI: ->
      @uri

    getTitle: ->
      'Build Tools Settings'

    getIconName: ->
      'tools'

    updateProjects: ->
      paths = atom.project.getPaths()
      @project_list.empty()
      small_paths = @removeSharedPath paths
      for path,i in small_paths
        @addProject path, paths[i]
      @project_list.on 'click', '.project-item', (e) =>
        @setActiveProject e.currentTarget

    addProject: (name, path) ->
      item = $$ ->
        @li class:'list-item project-item', =>
          @div class:'icon icon-book', name
          @div class:'text-subtle', path
      @project_list.append(item)
      if main.projects.getProject(path) is null
        main.projects.addProject(path)

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
      name = e.children[0].innerHTML
      path = e.children[1].innerHTML
      @markAsActive e
      @setContent name, path
      @activeProject = main.projects.getProject path

    getElement: (path) ->
      for e in @project_list.children()
        if e.children[1].innerHTML is path
          return e

    setContent: (name, path) ->
      @clearAll()
      @title.html name
      if (project = main.projects.getProject(path))?
        commands = project["commands"]
        for command in commands
          @addCommand command
      else
        main.projects.addProject(path)

    clearAll: ->
      @command_list.empty()
      @dependency_list.empty()

    clearDependencies: ->
      @dependency_list.empty()

    reload: =>
      if @commandview?.visible()
        @commandview.hide()
      @updateProjects()
      if main.projects.getProject(@activeProject)? and (e=@getElement(@activeProject))?
        @setActiveProject e
      else
        @setActiveProject @project_list.children()[0]

    markAsActive: (e) ->
      @project_list.find('.active').removeClass('active')
      e.classList.add('active')

    editcb: (oldname, items) =>
      if oldname?
        @activeProject.replaceCommand oldname, items
      else
        @activeProject.addCommand items

    addCommand: (items) ->
      item = $$ ->
        @div class:'command', =>
          @div class:'top', =>
            @div id:'info', class:'align', =>
              @div class:'icon-expand expander'
              @div id:'name', items.name
            @div id:'options', class:'align', =>
              @div class:'icon-edit'
              @div class:'icon-up'
              @div class:'icon-down'
              @div class:'icon-close'
          @div class:'info hidden', =>
            @div id:'general', =>
              @div class:'keys', =>
                @div "Command"
                @div "Working Directory"
                @div "Shell"
              @div class:'values', =>
                @div class:'text-highlight', items.command
                @div class:'text-highlight', items.wd
                @div class:'text-highlight', items.shell.toString()
            @div class:'streams', =>
              @div id:'stdout', class:'stream', =>
                @div class:'keys', =>
                  @div "Mark paths (stdout)"
                  @div "Highlighting (stdout)"
                  @div "Use Linter (stdout)"
                @div class:'values', =>
                  @div class:'text-highlight', items.stdout.file.toString()
                  @div class:'text-highlight', highlight_translation[items.stdout.highlighting]
                  @div class:'text-highlight', if /ht|hc/.test(items.stdout.highlighting) then items.stdout.lint.toString() else 'Disabled'
              @div id:'stderr', class:'stream', =>
                @div class:'keys', =>
                  @div "Mark paths (stderr)"
                  @div "Highlighting (stderr)"
                  @div "Use Linter (stderr)"
                @div class:'values', =>
                  @div class:'text-highlight', items.stderr.file.toString()
                  @div class:'text-highlight', highlight_translation[items.stderr.highlighting]
                  @div class:'text-highlight', if /ht|hc/.test(items.stderr.highlighting) then items.stderr.lint.toString() else 'Disabled'
      item.on 'click', '.icon-expand', (e) =>
        @reduceAll e.currentTarget.parentNode.parentNode.parentNode.parentNode
        @expandCommand e.currentTarget
      item.on 'click', '.icon-down', (e) =>
        target = e.currentTarget
        if target.classList.contains('expander')
          @reduceCommand target
        else
          @moveDown target.parentNode.parentNode.parentNode
      item.on 'click', '.icon-up', (e) =>
        @moveUp e.currentTarget.parentNode.parentNode.parentNode
      item.on 'click', '.icon-close', (e) =>
        @removeCommand e.currentTarget.parentNode.parentNode.parentNode
      item.on 'click', '.icon-edit', (e) =>
        @editCommand e.currentTarget.parentNode.parentNode.parentNode
      @command_list.append(item)

    expandCommand: (target) ->
      target.classList.remove 'icon-expand'
      target.classList.add 'icon-down'
      target.parentNode.parentNode.parentNode.children[1].classList.remove('hidden')
      target.parentNode.parentNode.classList.add('top-expanded')

    reduceCommand: (target) ->
      target.classList.remove 'icon-down'
      target.classList.add 'icon-expand'
      target.parentNode.parentNode.parentNode.children[1].classList.add('hidden')
      target.parentNode.parentNode.classList.remove('top-expanded')

    editCommand: (target) ->
      @CommandView ?= require './command-view'
      @commandview ?= new @CommandView(@editcb)
      id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
      cmd = @activeProject.getCommandByIndex id
      @commandview.show(cmd)

    reduceAll: (target) ->
      $(target).find('.expander').each (i,e) =>
        @reduceCommand e

    moveDown: (target) ->
      node = $(target)
      if node.index() isnt target.parentNode.childElementCount-1
        @activeProject.moveCommand $(target).find('#name').html(), 1

    moveUp: (target) ->
      node = $(target)
      if node.index() isnt 0
        @activeProject.moveCommand $(target).find('#name').html(), -1

    removeCommand: (target) ->
      @activeProject.removeCommand $(target).find('#name').html()
