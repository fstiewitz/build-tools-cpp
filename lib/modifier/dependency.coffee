{$, $$, View} = require 'atom-space-pen-views'
path = require 'path'

Command = null
Project = null
Input = null

resolveQueue = (queue, q, resolve, reject) ->
  return resolve(q) unless (c = queue.splice(0, 1)[0])?
  p = resolveCommands(c)
  p.then (new_q) -> resolveQueue(queue, q.concat(new_q.reverse()), resolve, reject)
  p.catch (e) -> reject(e)

resolveCommands = (input) ->
  q = []
  p = new Project(input.project, input.source)
  resolveCommand(input, q, p)

resolveCommand = (command, q, project) ->
  new Promise((resolve, reject) ->
    q.push command
    unless command.modifier.dependency?
      #project.destroy()
      return resolve(q)
    resolveDependency(command.modifier.dependency.list, q, project, resolve, reject)
  )

resolveDependency = (list, q, project, resolve, reject) ->
  unless (k = list.pop())?
    project.destroy()
    return resolve(q)
  p = project.getCommandById k[0], k[1]
  p.then (command) ->
    return reject("Command names #{command.name} and #{k[2]} do not match") if command.name isnt k[2]
    p = resolveCommand(command, q, project)
    p.then -> resolveDependency(list, q, project, resolve, reject)
    p.catch (e) -> reject(e)
  p.catch (e) -> reject(e)

module.exports =

  name: 'Dependencies'
  description: 'Execute other commands before this one.'
  private: false

  activate: (command, project, input) ->
    Command = command
    Project = project
    Input = input

  edit:
    class DependencyPane extends View

      @content: ->
        @div class: 'panel-body padded', =>
          @div class: 'dependency-list', =>
            @div class: 'active-dependencies', outlet: 'deps'
            @div class: 'dependency-select-list hidden', outlet: 'select'
            @div class: 'config-icons', =>
              @div id: 'add', class: 'icon-plus'
              @div id: 'cancel', class: 'icon-x hidden'
          @div class: 'block checkbox', =>
            @input id: 'abort', type: 'checkbox'
            @label =>
              @div class: 'settings-name', 'Abort when command not found'
              @div =>
                @span class: 'inline-block text-subtle', 'Cancel the operation if a command could not be resolved'

      set: (command, source) ->
        @find('#add').on 'click', =>
          try
            project = new Project(path.dirname(source), source)
            p = project.getCommandNameObjects()
            p.then (commands) =>
              @select.empty()
              for {pid, id, name} in commands
                item = $$ ->
                  @div class: 'dependency', pid: pid, id: id, name: name, =>
                    @div "#{pid}:#{id}:#{name}"
                item.on 'click', ({currentTarget}) =>
                  pid = currentTarget.attributes.getNamedItem('pid').value
                  id = currentTarget.attributes.getNamedItem('id').value
                  name = currentTarget.attributes.getNamedItem('name').value
                  @add [pid, id, name]
                  @cancel()
                @select.append item
              @deps.addClass('hidden')
              @select.removeClass('hidden')
              @find('#add').addClass('hidden')
              @find('#cancel').removeClass('hidden')
            p.catch (e) ->
              atom.notifications?.addError e
          catch
            atom.notifications?.addError "Could not read from config file #{source}"

        @find('#cancel').on 'click', => @cancel()

        @deps.empty()
        if command?.modifier.dependency?
          for dep in command.modifier.dependency.list
            @deps.append @generateItem(dep)
          @find('#abort').prop('checked', command.modifier.dependency.abort)
        else
          @find('#abort').prop('checked', true)

      get: (command) ->
        command.modifier.dependency = {}
        command.modifier.dependency.list = []
        command.modifier.dependency.abort = @find('#abort').prop('checked')
        for child in @deps.children()
          pid = child.attributes.getNamedItem('pid').value
          id = child.attributes.getNamedItem('id').value
          name = child.attributes.getNamedItem('name').value
          command.modifier.dependency.list.push [pid, id, name]
        return null

      add: (item) ->
        @deps.append @generateItem(item)

      cancel: ->
        @deps.removeClass('hidden')
        @select.addClass('hidden')
        @find('#add').removeClass('hidden')
        @find('#cancel').addClass('hidden')

      generateItem: ([pid, id, name]) ->
        item = $$ ->
          @div class: 'dependency', pid: pid, id: id, name: name, =>
            @div "#{pid}:#{id}:#{name}"
            @div class: 'actions', =>
              @div class: 'icon-triangle-up'
              @div class: 'icon-triangle-down'
              @div class: 'icon-x'
        item.on 'click', '.icon-triangle-down', ({currentTarget}) ->
          i = $(currentTarget.parentNode.parentNode)
          i.next().after(i)
        item.on 'click', '.icon-triangle-up', ({currentTarget}) ->
          i = $(currentTarget.parentNode.parentNode)
          i.prev().before(i)
        item.on 'click', '.icon-x', ({currentTarget}) ->
          $(currentTarget.parentNode.parentNode).remove()
        return item

  info:
    class DepInfoPane
      constructor: (command) ->
        @element = document.createElement 'div'
        @element.classList.add 'module'
        keys = document.createElement 'div'
        values = document.createElement 'div'

        for [pid, id, name] in command.modifier.dependency.list
          _key = document.createElement 'div'
          _key.classList.add 'text-padded'
          _key.innerText = "Dependency #{pid}:#{id}:"

          value = document.createElement 'div'
          value.classList.add 'text-padded'
          value.innerText = name

          keys.appendChild _key
          values.appendChild value

        _key = document.createElement 'div'
        _key.classList.add 'text-padded'
        _key.innerText = 'Abort on resolve error:'

        value = document.createElement 'div'
        value.classList.add 'text-padded'
        value.innerText = String(command.modifier.dependency.abort)

        keys.appendChild _key
        values.appendChild value

        @element.appendChild keys
        @element.appendChild values

  in: (queue) ->
    new Promise((resolve, reject) ->
      p = new Promise((resolve, reject) -> resolveQueue(queue.queue, [], resolve, reject))
      p.then (q) ->
        queue.queue = q
        resolve()
      p.catch (e) -> reject(e)
    )
