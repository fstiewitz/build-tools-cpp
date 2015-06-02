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
      @div id:'from', =>
        @div class:'small-header', 'Command'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Project Name'
            @div =>
              @span class:'text-subtle', 'Cannot be changed'
          @select disabled:"yes", class:'project form-control', outlet: 'project_from'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Command Name'
          @select class:'command form-control', outlet: 'command_from'
      @div id:'to', =>
        @div class:'small-header', 'depends on'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Project Name'
          @select class:'project form-control', outlet: 'project_to'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Command Name'
          @select class:'command form-control', outlet: 'command_to'

  initialize: (@callback,@projects) ->
    @disposables = new CompositeDisposable
    @on 'change', '.project', (e) =>
      @selectedProject e.currentTarget

    @disposables.add atom.commands.add @element, 'core:confirm': (event) =>
        if @validInput()
          @callback(@oldid, {
            from: @command_from.children()[@command_from[0].selectedIndex].innerHTML,
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

  show: (project, items, @oldid) ->
    @updateProjects()
    e = @project_from.find('[value="' + project + '"]')[0]
    @project_from[0].selectedIndex = if e? then Array.prototype.indexOf.call(e.parentNode.childNodes, e) else 0
    @selectedProject @project_from[0]
    if items?
      e = @command_from.find('[value="' + items.from + '"]')[0]
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
    f = (o) ->
      o.children[o.selectedIndex]?.prop('value') isnt ''
    f(@project_from) and f(@command_from) and f(@project_to) and f(@project_from)

  updateProjects: ->
    @project_from.empty()
    @project_to.empty()
    @command_from.empty()
    @command_to.empty()

    @command_from.append(@defaultcommand())
    @command_to.append(@defaultcommand())

    projects = @projects.getProjects()
    if projects.length is 0
      @project_from.append(@defaultproject())
      @project_to.append(@defaultproject())
      return
    for project in projects
      item = ->
        $$ ->
          @option value:project, project
      @project_from.append(item())
      @project_to.append(item())
    @project_to[0].selectedIndex = 0
    @selectedProject @project_to[0]

  selectedProject: (e) ->
    project = e.children[e.selectedIndex].innerHTML
    if e.parentNode.parentNode.id is 'from'
      c = @command_from
    else if e.parentNode.parentNode.id is 'to'
      c = @command_to
    else
      return
    c.empty()
    if project is 'Select project'
      c.append @defaultcommand()
      return
    if (p = @projects.getProject(project))?
      for command in p.commands
        c.append $$ ->
          @option value:command.name, command.name
