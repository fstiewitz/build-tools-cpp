module.exports =
  linter: null
  v1disabled: false
  update: ->
    unless @linter
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'linter:lint')
      return
    @linter.setAllMessages(@convertToV2(m) for m in @messages)

  messages: []

  convertToV2: ({filePath, range, type, text, linterName = "build-tools"}) ->
    location:
      file: filePath
      position: range
    excerpt: text.split("\n")[0]
    severity: type
    description: text.split("\n").slice(1).join("\n")
    linterName: linterName
