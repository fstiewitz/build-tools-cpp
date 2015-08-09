{$, $$, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class ImportView extends View
    @content: ->
      @div class: 'import-view', =>
        @div class: 'inset-panel', =>
          @div class: 'panel-heading settings-name icon icon-cloud-download', 'Import'
          @div class: 'panel-body', =>
            @ul class: 'list-tree has-collapsable-children', outlet: 'tree'
            @div id: 'error-none', class: 'error hidden', 'Nothing selected'
        @div class: 'block checkbox', =>
          @input id: 'show-all', type: 'checkbox'
          @label =>
            @div class: 'settings-name', 'Show all projects'
        @div class: 'buttons', =>
          @div class: 'btn btn-error icon icon-x inline-block-tight', 'Cancel'
          @div class: 'btn btn-primary icon icon-check inline-block-tight', 'Accept'

    initialize: (@projects) ->
      @disposables = new CompositeDisposable

      @on 'click', '.buttons .icon-x', @cancel
      @on 'click', '.buttons .icon-check', @accept

      @disposables.add atom.commands.add @element,
        'core:confirm': @accept
        'core:cancel': @cancel

      @show_all = false
      @on 'change', '#show-all', (e) =>
        @show_all = $(e.currentTarget).prop('checked')
        @reload()
      @on 'click', '.checkbox label', (e) =>
        item = $(e.currentTarget.parentNode.children[0])
        item.prop('checked', not item.prop('checked'))
        @show_all = item.prop('checked')
        @reload()

    destroy: ->
      @disposables.dispose()
      @detach()

    accept: (event) =>
      if @validInput()
        if not @dependencies
          selected = @find('.selected')
          project = selected[0].parentNode.parentNode.children[0].children[0].innerHTML
          command = selected[0].children[0].innerHTML
          @hide()
          event.stopPropagation()
          @callback(@projects.data[project].getCommand command)
        else
          selected = @find('.selected')
          project = selected[0].parentNode.parentNode.children[0].children[0].innerHTML
          dependency = Array.prototype.indexOf.call(selected[0].parentNode.childNodes, selected[0])
          @hide()
          event.stopPropagation()
          dependency = $.extend(true, {}, @projects.data[project].dependencies[dependency])
          dependency.from.project = @project
          @callback(dependency)
      else
        @find('#error-none').removeClass 'hidden'

    validInput: ->
      @tree.find('.selected').length isnt 0

    cancel: (event) =>
      @hide()
      event.stopPropagation()

    hide: ->
      @panel?.hide()

    visible: ->
      if @panel?
        return @panel.isVisible()
      else
        return false

    click: (e) ->
      @tree.find('.selected').removeClass 'selected'
      e.classList.add 'selected'

    collapse: (e) ->
      e.parentNode.classList.toggle 'collapsed'

    show: (@dependencies, @callback, @project) ->
      if atom.inSpecMode()
        @show_all = true
      else
        @show_all = false
      @find('#show-all').prop('checked', @show_all)
      @reload()
      @panel ?= atom.workspace.addModalPanel(item: this)
      @parent('.modal').css(
        'max-height': '100%'
        display: 'flex'
        'flex-direction': 'column'
      )
      @panel.show()

    reload: ->
      @find('#error-none').addClass 'hidden'
      @tree.empty()
      @tree.off 'click'
      if @show_all
        paths = @projects.getProjects()
      else
        paths = atom.project.getPaths()
      for project in paths
        @addProject @projects.data[project] if @projects.data[project]?
      @tree.on 'click', '.project', (e) => @collapse e.currentTarget

    addProject: (project) ->
      item = $$ ->
        @li class: 'list-nested-item', =>
          @div class: 'list-item project', =>
            @span class: 'icon icon-repo', project.path
          @ul class: 'list-tree'
      item.addClass 'collapsed' if project.path isnt @project
      if not @dependencies
        for command in project.commands
          @addCommand item, command
      else
        for dependency in project.dependencies
          @addDependency item, dependency
      item.on 'click', '.item', (e) => @click e.currentTarget
      @tree.append item

    addCommand: (item, command) ->
      entry = $$ ->
        @li class: 'list-item item', =>
          @span class: 'icon icon-terminal', command.name
      item.find('.list-tree').append entry

    addDependency: (item, dependency) ->
      entry = $$ ->
        @li class: 'list-item item', =>
          @span class: 'icon icon-link', =>
            @span dependency.from.command
            @span class: 'icon icon-arrow-right'
            @span dependency.to.project + ':' + dependency.to.command
      item.find('.list-tree').append entry
