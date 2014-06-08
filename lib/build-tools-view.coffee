{$,Point,View} = require 'atom'
parser = require './build-parser.coffee'

module.exports =
class BuildToolsCommandOutput extends View
  @content: ->
    @div class: 'build-tools-cpp', =>
      @div class:"commandheader horizontal", =>
        @div class:"commandname"
        @div class:"commandclose"
      @div class:"commandoutput", outlet:"cmd_output"

  initialize: ->
    $(document).on 'click','.commandclose', =>
      @hideBox()
    return

  serialize: ->

  destroy: ->
    @detach()

  attach: ->
    atom.workspaceView.appendToBottom(this)

  show: ->
    @showBox() if !@visible
    @showHeaderLineOnly()

  hide: ->
    @hideBox() if @visible

  hideBox: ->
    @detach()
    @visible = false

  showBox: ->
    @attach()
    @visible = true

  showHeaderLineOnly: ->
    $(document).find(".commandoutput").addClass("build-tools-cpp-hidden")

  showOutput: ->
    $(document).find(".commandoutput").removeClass("build-tools-cpp-hidden")

  toggleBox: ->
    if @visible
      @hideBox()
    else
      @showBox()

  clear: ->
    $(document).find(".commandoutput").text('')
    parser.clearVars()

  outputLineParsed: (line,script) =>
    line = line.toString()
    parser.toLine line, script, @printLine

  openFile: (element) ->
    lineno = parseInt($(this).attr('row'))
    linecol= parseInt($(this).attr('col'))
    if $(this).attr('name') != ''
      atom.workspaceView.open($(this).attr('name')).then (editor) ->
        if lineno != 0
          editor.setCursorBufferPosition([lineno-1,linecol-1])

  finishConsole: ->
    if atom.config.get('build-tools-cpp.ErrorHighlighting')
      $(document).find(".filelink").on 'click', @openFile

  printLine: (message) =>
    @showOutput() if !@lockoutput
    @cmd_output.append(message)
    @cmd_output.scrollTop(@cmd_output[0].scrollHeight)

  setHeader: (name) ->
    $(document).find(".commandname").html("<b>#{name}</b>")

  setHeaderOnly: (text) ->
    @showHeaderLineOnly()
    $(document).find(".commandname").html("<b>#{text}</b>")

  lock: ->
    @lockoutput = true

  unlock: ->
    @lockoutput = false

  visible: false
  lockoutput: false
