ColorRegex = /\x1b\[[0-9;]*m/g
Escape = /\x1b/

module.exports =
  modifier:
    class RemoveAsciiModifier

      constructor: ->
        @endsWithAnsi = null

      destroy: ->
        @endsWithAnsi = null

      modify: ({temp}) ->
        line = temp.input
        line = line.replace(ColorRegex, '')
        if @endsWithAnsi?
          _part = @endsWithAnsi + line
          if ColorRegex.test(_part)
            line = _part.replace(ColorRegex, '')
            @endsWithAnsi = null
          else
            @endsWithAnsi = _part
            line = ''
        if (m = Escape.exec(line))?
          @endsWithAnsi = line.substr(m.index)
          line = data.substr(0, m.index)
        temp.input = line
        return null
