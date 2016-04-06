Ansi = /\x1b\[(\d[ABCDEFGJKST]|\d;\d[Hf]|[45]i|6n|[su]|\?25[lh]|[0-9;]*m)/g
AnsiStart = /^\x1b\[(\d[ABCDEFGJKST]|\d;\d[Hf]|[45]i|6n|[su]|\?25[lh]|[0-9;]*m)/
AnsiEnd = /\x1b\[?(\d?|\d?;?\d?|[45]?|6?|\??2?5?|[0-9;]*)$/

module.exports =

  name: 'Remove ANSI Codes'

  edit:
    class AllSaver
      get: (command, stream) ->
        command[stream].pipeline.push name: 'remansi'
        return null

  modifier:
    class RemoveANSIModifier

      constructor: ->
        @endsWithAnsi = null

      destroy: ->
        @endsWithAnsi = null

      modify_raw: (input) ->
        input = input.replace(Ansi, '')
        if @endsWithAnsi?
          _part = @endsWithAnsi + input
          if AnsiStart.test(_part)
            input = _part.replace(Ansi, '')
            @endsWithAnsi = null
          else
            @endsWithAnsi = _part
            input = ''
        if (m = AnsiEnd.exec(input))?
          @endsWithAnsi = input.substr(m.index)
          input = input.substr(0, m.index)
        return input
