Ansi = /\x1b\[(\d[ABCDEFGJKST]|\d;\d[Hf]|[45]i|6n|[su]|\?25[lh]|[0-9;]*m)/g
AnsiStart = /^\x1b\[(\d[ABCDEFGJKST]|\d;\d[Hf]|[45]i|6n|[su]|\?25[lh]|[0-9;]*m)/
AnsiEnd = /\x1b\[?(\d?|\d?;?\d?|[45]?|6?|\??2?5?|[0-9;]*)$/

module.exports =
  modifier:
    class RemoveANSIModifier

      constructor: ->
        @endsWithAnsi = null

      destroy: ->
        @endsWithAnsi = null

      modify: ({temp}) ->
        line = temp.input
        line = line.replace(Ansi, '')
        if @endsWithAnsi?
          _part = @endsWithAnsi + line
          if AnsiStart.test(_part)
            line = _part.replace(Ansi, '')
            @endsWithAnsi = null
          else
            @endsWithAnsi = _part
            line = ''
        if (m = AnsiEnd.exec(line))?
          @endsWithAnsi = line.substr(m.index)
          line = line.substr(0, m.index)
        temp.input = line
        return null
