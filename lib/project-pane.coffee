{$, $$, ScrollView} = require 'atom-space-pen-views'
Profiles = require './profiles/profiles'

ImportView = null
DependencyView = null
CommandInfoPane = null

module.exports =
  class ProjectPane extends ScrollView

    importview: null
    dependencyview: null

    @content: ->
      @div class: 'inset-panel', =>
        @div class: 'panel-heading icon icon-book', outlet: 'title'
        @div class: 'panel-body', =>
          @div class: 'inset-panel', =>
            @div class: 'panel-heading icon icon-keyboard', 'Key bindings'
            @div class: 'panel-body padded', =>
              @div class: 'key-bind', =>
                @div class: 'key-desc', 'First Command'
                @div id: 'make', class: 'key-value', =>
                  @div class: 'btn-group', =>
                    @button id: 'local', class: 'btn selected', 'Local'
                    @button id: 'custom-value', class: 'btn hidden'
                    @button id: 'custom', class: 'btn', 'Custom'
              @div class: 'key-bind', =>
                @div class: 'key-desc', 'Second Command'
                @div id: 'configure', class: 'key-value', =>
                  @div class: 'btn-group', =>
                    @button id: 'local', class: 'btn selected', 'Local'
                    @button id: 'custom-value', class: 'btn hidden'
                    @button id: 'custom', class: 'btn', 'Custom'
              @div class: 'key-bind', =>
                @div class: 'key-desc', 'Third Command'
                @div id: 'preconfigure', class: 'key-value', =>
                  @div class: 'btn-group', =>
                    @button id: 'local', class: 'btn selected', 'Local'
                    @button id: 'custom-value', class: 'btn hidden'
                    @button id: 'custom', class: 'btn', 'Custom'
          @div class: 'inset-panel', =>
            @div class: 'panel-heading icon icon-code', =>
              @span class: 'section-header', 'Commands'
              @span id: 'add-command-button', class: 'inline-block btn btn-xs icon icon-plus', 'Add command'
              @span id: 'import-command-button', class: 'inline-block btn btn-xs icon icon-cloud-download', 'Import command'
            @div class: 'panel-body padded', =>
              @div class: 'command-list', outlet: 'command_list'
          @div class: 'inset-panel', =>
            @div class: 'panel-heading icon icon-circuit-board', =>
              @span class: 'section-header', 'Dependencies'
              @span id: 'add-dependency-button', class: 'inline-block btn btn-xs icon icon-plus', 'Add dependency'
              @span id: 'import-dependency-button', class: 'inline-block btn btn-xs icon icon-cloud-download', 'Import dependency'
            @div class: 'panel-body padded', =>
              @div class: 'dependency-list', outlet: 'dependency_list'

    initialize: (@projects, @commandpane_show) ->
      @dependencyview = null
      @importview = null

      @on 'click', '#add-command-button', (e) =>
        @commandpane_show(null, null, @activeProject)
      @on 'click', '#add-dependency-button', (e) =>
        DependencyView ?= require './dependency-view'
        @dependencyview ?= new DependencyView(@editdcb, @projects)
        @dependencyview.show(@activeProject.path)
      @on 'click', '#import-command-button', (e) =>
        ImportView ?= require './import-view'
        @importview ?= new ImportView(@projects)
        @importview.show(false, @importccb, @activeProject.path)
      @on 'click', '#import-dependency-button', (e) =>
        ImportView ?= require './import-view'
        @importview ?= new ImportView(@projects)
        @importview.show(true, @importdcb, @activeProject.path)
      @on 'click', '.key-value .btn-group .btn', (e) =>
        key = e.currentTarget.parentNode.parentNode.id
        if e.currentTarget.id is 'local'
          @activeProject.clearKey key
          group = $(e.currentTarget.parentNode)
          group.find('.selected').removeClass('selected')
          e.currentTarget.classList.add('selected')
          @activeProject.clearKey key
        else if e.currentTarget.id is 'custom'
          ImportView ?= require './import-view'
          @importview ?= new ImportView(@projects)
          @importview.show(false, (command) =>
            @selectccb(key, command)
          , @activeProject.path)
        else
          group = $(e.currentTarget.parentNode)
          group.find('.selected').removeClass('selected')
          e.currentTarget.classList.add('selected')

    destroy: ->
      @detach()
      @dependencyview?.destroy()
      @dependencyview = null
      @importview?.destroy()
      @importview = null
      @projects = null
      @activeProject = null
      @commandpane_show = null

    setContent: (@activeProject, name) ->
      @clearAll()
      @title.html name
      if @activeProject?
        @setKeybinding 'make', @activeProject.key.make
        @setKeybinding 'configure', @activeProject.key.configure
        @setKeybinding 'preconfigure', @activeProject.key.preconfigure
        for command in @activeProject.commands
          @addCommand command
        for dependency in @activeProject.dependencies
          @addDependency dependency

    setKeybinding: (key, binding) ->
      if binding?
        btn_group = @find("\##{key}")
        btn = btn_group.find('#custom-value')
        btn.html("#{binding.project}:#{binding.command}")
        btn_group.find('.selected').removeClass('selected')
        btn.removeClass('hidden')
        btn.addClass('selected')
      else
        btn_group = @find("\##{key}")
        btn_group.find('#custom-value').addClass('hidden')
        btn_group.find('.selected').removeClass('selected')
        btn_group.find('#local').addClass('selected')

    clearAll: ->
      @command_list.empty()
      @dependency_list.empty()

    clearDependencies: ->
      @dependency_list.empty()

    hideModals: ->
      if @dependencyview?.visible()
        @dependencyview.hide()
      if @importview?.visible()
        @importview.hide()

    editccb: (oldname, items) =>
      if oldname?
        @activeProject.replaceCommand oldname, items
      else
        @activeProject.addCommand items

    editdcb: (oldid, items) =>
      if oldid?
        @activeProject.replaceDependency oldid, items
      else
        @activeProject.addDependency items

    importccb: (command) =>
      @commandpane_show(null, command, @activeProject)

    importdcb: (dependency) =>
      DependencyView ?= require './dependency-view'
      @dependencyview ?= new DependencyView(@editdcb, @projects)
      @dependencyview.show(dependency.from.project, dependency, null)

    selectccb: (key, command) =>
      @activeProject.setKey key,
        project: command.project
        command: command.name

    addCommand: (command) ->
      CommandInfoPane ?= require './command-info-pane'
      item = new CommandInfoPane(command)
      item.on 'click', '.icon-triangle-right', (e) =>
        @reduceAll e.currentTarget.parentNode.parentNode.parentNode.parentNode
        @expandCommand e.currentTarget
      item.on 'click', '.icon-triangle-down', (e) =>
        target = e.currentTarget
        if target.classList.contains('expander')
          @reduceCommand target
        else
          @moveCommandDown target.parentNode.parentNode.parentNode
      item.on 'click', '.icon-triangle-up', (e) =>
        @moveCommandUp e.currentTarget.parentNode.parentNode.parentNode
      item.on 'click', '.icon-x', (e) =>
        @removeCommand e.currentTarget.parentNode.parentNode.parentNode
      item.on 'click', '.icon-pencil', (e) =>
        @editCommand e.currentTarget.parentNode.parentNode.parentNode
      @command_list.append(item)

    addDependency: (items) ->
      item = $$ ->
        @div class: 'dependency', =>
          @div class: 'align', =>
            @span class: 'text-info', items.from.command
            @span class: 'dep', ' depends on '
            @span class: 'text-info', items.to.project
            @span ':'
            @span class: 'text-info', items.to.command
          @div id: 'options', =>
            @div class: 'icon-pencil'
            @div class: 'icon-triangle-up'
            @div class: 'icon-triangle-down'
            @div class: 'icon-x'
      item.on 'click', '.icon-pencil', (e) =>
        @editDependency e.currentTarget.parentNode.parentNode
      item.on 'click', '.icon-triangle-up', (e) =>
        @moveDependencyUp e.currentTarget.parentNode.parentNode
      item.on 'click', '.icon-triangle-down', (e) =>
        @moveDependencyDown e.currentTarget.parentNode.parentNode
      item.on 'click', '.icon-x', (e) =>
        @removeDependency e.currentTarget.parentNode.parentNode
      @dependency_list.append(item)

    expandCommand: (target) ->
      target.classList.remove 'icon-triangle-right'
      target.classList.add 'icon-triangle-down'
      target.parentNode.parentNode.parentNode.children[1].classList.remove('hidden')
      target.parentNode.parentNode.classList.add('top-expanded')

    reduceCommand: (target) ->
      target.classList.remove 'icon-triangle-down'
      target.classList.add 'icon-triangle-right'
      target.parentNode.parentNode.parentNode.children[1].classList.add('hidden')
      target.parentNode.parentNode.classList.remove('top-expanded')

    editCommand: (target) ->
      id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
      cmd = @activeProject.getCommandByIndex id
      @commandpane_show(cmd.name, cmd, @activeProject)

    editDependency: (target) ->
      DependencyView ?= require './dependency-view'
      @dependencyview ?= new DependencyView(@editdcb, @projects)
      id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
      @dependencyview.show(@activeProject.path, @activeProject.dependencies[id], id)

    reduceAll: (target) ->
      $(target).find('.expander').each (i, e) =>
        @reduceCommand e

    moveCommandDown: (target) ->
      node = $(target)
      if node.index() isnt target.parentNode.childElementCount - 1
        @activeProject.moveCommand $(target).find('#name').html(), 1

    moveDependencyDown: (target) ->
      node = $(target)
      if node.index() isnt target.parentNode.childElementCount - 1
        id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
        @activeProject.moveDependency id, 1

    moveCommandUp: (target) ->
      node = $(target)
      if node.index() isnt 0
        @activeProject.moveCommand $(target).find('#name').html(), -1

    moveDependencyUp: (target) ->
      node = $(target)
      if node.index() isnt 0
        id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
        @activeProject.moveDependency id, -1

    removeCommand: (target) ->
      @activeProject.removeCommand $(target).find('#name').html()

    removeDependency: (target) ->
      id = Array.prototype.indexOf.call(target.parentNode.childNodes, target)
      @activeProject.removeDependency id
