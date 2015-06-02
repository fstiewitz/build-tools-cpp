{$$,View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class DependencyView extends View
  defaultproject: ->
    $$ ->
      @option value:'', 'Select project'
  defaultcommand: ->
    $$ ->
      @option value:'', 'Select project first'

  @content: ->
    @div class:'dependency-view', =>
      @div class:'align from', =>
        @select class:'project form-control', outlet: 'project_from'
        @select class:'command form-control', outlet: 'command_from'
      @div class:'align to', =>
        @select class:'project form-control', outlet: 'project_to'
        @select class:'command form-control', outlet: 'command_to'

  initialize: (@callback,@projects) ->
    @disposables = new CompositeDisposable
    @on 'change', '.project', (e) =>
      @selectedProject e.currentTarget

    @disposables.add atom.commands.add @element, 'core:confirm': (event) =>
        if @validInput()
          @callback(@oldid, {
            from: {
              project: @project_from.children()[@project_from[0].selectedIndex].innerHTML,
              command: @command_from.children()[@command_from[0].selectedIndex].innerHTML
            },
            to: {
              project: @project_to.children()[@project_to[0].selectedIndex].innerHTML,
              command: @command_to.children()[@command_to[0].selectedIndex].innerHTML
            }
            })
          @hide()
        event.stopPropagation()

    @disposables.add atom.commands.add @element, 'core:cancel': (event) =>
        @hide()
        event.stopPropagation()

  destroy: ->
    @disposables.dispose()
    @detach()

  hide: ->
    @panel?.hide()

  visible: ->
    if @panel?
      return @panel.isVisible()
    else
      return false

  show: (items, @oldid) ->
    @updateProjects()
    if items?
      e = @project_from.find('[value="' + items.from.project + '"]')[0]
      @project_from[0].selectedIndex = if e? then Array.prototype.indexOf.call(e.parentNode.childNodes, e) else 0
      @selectedProject @project_from[0]

      e = @command_from.find('[value="' + items.from.command + '"]')[0]
      @command_from[0].selectedIndex = if e? then Array.prototype.indexOf.call(e.parentNode.childNodes, e) else 0

      e = @project_to.find('[value="' + items.to.project + '"]')[0]
      @project_to[0].selectedIndex = if e? then Array.prototype.indexOf.call(e.parentNode.childNodes, e) else 0
      @selectedProject @project_to[0]

      e = @command_to.find('[value="' + items.to.command + '"]')[0]
      @command_to[0].selectedIndex = if e? then Array.prototype.indexOf.call(e.parentNode.childNodes, e) else 0

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @project_from.focus()

  validInput: ->
    (@project_from[0].selectedIndex isnt 0) and (@command_from[0].selectedIndex isnt 0) and (@project_to[0].selectedIndex isnt 0) and (@command_to[0].selectedIndex isnt 0)

  updateProjects: ->
    @project_from.empty()
    @project_to.empty()
    @command_from.empty()
    @command_to.empty()

    @project_from.append(@defaultproject())
    @project_to.append(@defaultproject())
    @command_from.append(@defaultcommand())
    @command_to.append(@defaultcommand())

    projects = @projects.getProjects()
    for project in projects
      item = ->
        $$ ->
          @option value:project, project
      @project_from.append(item())
      @project_to.append(item())

  selectedProject: (e) ->
    project = e.children[e.selectedIndex].innerHTML
    if e.parentNode.classList.contains 'from'
      c = @command_from
    else if e.parentNode.classList.contains 'to'
      c = @command_to
    else
      return
    c.empty()
    c.append @defaultcommand()
    return if project is 'Select project'
    if (p = @projects.getProject(project))?
      for command in p.commands
        item = $$ ->
          @option value:command.name, command.name
        c.append item
