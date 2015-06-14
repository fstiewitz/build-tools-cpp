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

  nocommand: ->
    $$ ->
      @option value:'', 'Project has no commands'

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
          @div id:'source-project-none', class:'error hidden', 'Select a project'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Command Name'
          @select class:'command form-control', outlet: 'command_from'
          @div id:'source-command-select', class:'error hidden', 'Select a command'
          @div id:'source-command-none', class:'error hidden', 'Project has no command'
      @div id:'to', =>
        @div class:'small-header', 'depends on'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Project Name'
          @select class:'project form-control', outlet: 'project_to'
          @div id:'dest-project-none', class:'error hidden', 'Select a project'
        @div class:'block', =>
          @label =>
            @div class:'settings-name', 'Command Name'
          @select class:'command form-control', outlet: 'command_to'
          @div id:'dest-command-select', class:'error hidden', 'Select a command'
          @div id:'dest-command-none', class:'error hidden', 'Project has no command'
      @div class:'buttons', =>
        @div class: 'btn btn-error icon icon-close inline-block-tight', 'Cancel'
        @div class: 'btn btn-primary icon icon-check inline-block-tight', 'Accept'

  initialize: (@callback,@projects) ->
    @disposables = new CompositeDisposable
    @on 'change', '.project', (e) =>
      @selectedProject e.currentTarget

    @on 'click', '.buttons .icon-close', @cancel
    @on 'click', '.buttons .icon-check', @accept

    @disposables.add atom.commands.add @element,
      'core:confirm': @accept
      'core:cancel': @cancel

  destroy: ->
    @disposables.dispose()
    @detach()

  accept: (event) =>
    @find('.error').addClass('hidden')
    {sp,sc} = @validSource()
    {dp,dc} = @validDest()
    if (not sp) or (sc isnt 0) or (not dp) or (dc isnt 0)
      @find('#source-project-none').removeClass('hidden') if not sp
      @find('#source-command-select').removeClass('hidden') if sc is 1
      @find('#source-command-none').removeClass('hidden') if sc is 2
      @find('#dest-project-none').removeClass('hidden') if not dp
      @find('#dest-command-select').removeClass('hidden') if dc is 1
      @find('#dest-command-none').removeClass('hidden') if dc is 2
    else
      @callback(@oldid,
        from:
          project: ''
          command: @command_from.children()[@command_from[0].selectedIndex].innerHTML
        to:
          project: @project_to.children()[@project_to[0].selectedIndex].innerHTML
          command: @command_to.children()[@command_to[0].selectedIndex].innerHTML
      )
      @hide()
    event.stopPropagation()

  validSource: ->
    if (sp=@projects.data[@project]?)
      c = @command_from.children()[@command_from[0].selectedIndex].innerHTML
      if c is 'Project has no commands'
        {sp: true, sc: 2}
      else
        {sp: true, sc: if (@projects.data[@project].getCommandIndex c) isnt -1 then 0 else 1}
    else
      {sp: false, sc: 0}

  validDest: ->
    p = @project_to.children()[@project_to[0].selectedIndex].innerHTML
    if (dp=@projects.data[p]?)
      c = @command_to.children()[@command_to[0].selectedIndex].innerHTML
      if c is 'Project has no commands'
        {dp: true, dc: 2}
      else
        {dp: true, dc: if (@projects.data[p].getCommandIndex c) isnt -1 then 0 else 1}
    else
      {dp: false, dc: 0}

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

  show: (@project, items, @oldid) ->
    @find('#source-project-none').addClass('hidden')
    @find('#source-command-select').addClass('hidden')
    @find('#source-command-none').addClass('hidden')
    @find('#dest-project-none').addClass('hidden')
    @find('#dest-command-select').addClass('hidden')
    @find('#dest-command-none').addClass('hidden')
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
      if p.commands.length isnt 0
        for command in p.commands
          c.append $$ ->
            @option value:command.name, command.name
      else
        c.append @nocommand()
