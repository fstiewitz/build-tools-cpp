{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
  class ConsoleView extends View
    @content: ->
      @div class: 'console', =>
        @div class: 'header', =>
          @div class: 'name bold', outlet: 'name'
          @div class: 'icons', =>
            @div class: 'icon-x', outlet: 'close_view'
        @div class: 'console-container', outlet: 'console', =>
          @div class: 'tabs', =>
            @span class: 'icon icon-three-bars'
            @ul class: 'tab-list', outlet: 'tabs'
          @div tabindex: '-1', class: 'output-container native-key-bindings', outlet: 'output'
          @div class: 'input-container', outlet: 'input_container', =>
            @subview 'input', new TextEditorView(mini: true, placeholderText: 'Write to standard input')

    initialize: (@model) ->
      @close_view.on 'click', =>
        @hide()
      @on 'mousedown', '.header', @startResize

      @model.onCreateTab @createTab
      @model.onFocusTab @focusTab
      @model.onRemoveTab @removeTab

      @active = null

    attached: ->
      @disposable = atom.commands.add @input.element, 'core:confirm': =>
        t = @input.getModel().getText()
        @input.getModel().setText('')
        @active.input? "#{t}\n"

    detached: ->
      @disposable.dispose()

    hideInput: ->
      @input_container.addClass 'hidden'
      atom.views.getView(atom.workspace).focus()

    startResize: (e) =>
      $(document).on 'mousemove', @resize
      $(document).on 'mouseup', @endResize
      @padding = $(document.body).height() - (e.clientY + @find('.output-container').height())

    resize: ({pageY, which}) =>
      return @endResize() unless which is 1
      @find('.output-container').height($(document.body).height() - pageY - @padding)

    endResize: =>
      $(document).off 'mousemove', @resize
      $(document).off 'mouseup', @endResize

    createTab: (tab) =>
      @tabs.append tab.header
      tab.header.on 'click', '.clicker', -> tab.focus()

    focusTab: (tab) =>
      @show()
      @tabs.find('.active').removeClass('active')
      @output.find('.output').addClass('hidden')
      @active = tab
      @name.empty()
      return @hide() unless tab?
      tab.header.addClass 'active'
      @name.append(tab.getHeader())
      if @active.view.hasClass 'hidden'
        @active.view.removeClass 'hidden'
      else
        @output.append @active.view
      @input_container[if @active.input? then 'removeClass' else 'addClass'] 'hidden'

    removeTab: (tab) =>
      if @active is tab
        $(tab.title).remove()
        @focusTab @getNextTab()
      tab.header.remove()
      tab.view.remove()

    getNextTab: ->
      return if @tabs.children().length <= 1
      for tab, index in @tabs.children()
        if tab is @active.header[0]
          if index is @tabs.children().length - 1
            header = @tabs.children()[index - 1]
            return @model.getTab(project: header.attributes.getNamedItem('project').value, name: header.attributes.getNamedItem('name').value)
          else
            header = @tabs.children()[index + 1]
            return @model.getTab(project: header.attributes.getNamedItem('project').value, name: header.attributes.getNamedItem('name').value)
