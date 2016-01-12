ColorRegex = /\x1b\[([0-9;]*)m/g
ColorRegexEnd = /\x1b\[?[0-9;]*$/

module.exports =

  classToStyle: (className) ->
    styles = []
    for style in className.split ' '
      styles.push parseInt(style.substr(1))
    return styles

  ansiToStyle: (ansi) ->
    styles = [-1, -1, -1]
    return [0, 0, 0] if ansi is ''
    for style in ansi.split ';'
      if (i = parseInt(style)) >= 30 and i <= 37
        styles[0] = i
      else if i >= 40 and i <= 47
        styles[1] = i
      else if i is 39
        styles[0] = 0
      else if i is 49
        styles[1] = 0
      else if i in [1, 3, 4]
        styles[2] = i
      else if i >= 21 and i <= 24
        styles[2] = i
      else if i is 0
        styles = [0, 0, 0]
    return styles

  styleToClass: (styles) ->
    classNames = []
    for style in styles
      classNames.push "a#{style}"
    return classNames.join ' '

  copyAttributes: (elements, id) ->
    e1 = elements[id]
    e2 = elements[id - 1]
    if e1? and e2?
      if (e = e2.children).length isnt 0
        e1.className = e[e.length - 1].className
        e1.setAttribute('nextStyle', v) if (v = e[e.length - 1].getAttribute('nextStyle'))?
        e1.setAttribute('endsWithAnsi', v) if (v = e[e.length - 1].getAttribute('endsWithAnsi'))
      else
        e1.className = e2.className
        e1.setAttribute('nextStyle', v) if (v = e2.getAttribute('nextStyle'))
        e1.setAttribute('endsWithAnsi', v) if (v = e2.getAttribute('endsWithAnsi'))

  getEndsWithAnsi: (elements, id) ->
    if elements[id - 1]?
      if (e = elements[id - 1].children).length isnt 0
        endsWithAnsi = e[e.length - 1].getAttribute('endsWithAnsi') ? ''
      else
        endsWithAnsi = elements[id - 1].getAttribute('endsWithAnsi') ? ''
      return endsWithAnsi
    else
      return ''

  getNextStyle: (elements, id) ->
    if elements[id - 1]?
      if (e = elements[id - 1].children).length isnt 0
        lastStyle = e[e.length - 1].getAttribute('nextStyle') ? e[e.length - 1].className
      else
        lastStyle = elements[id - 1].getAttribute('nextStyle') ? elements[id - 1].className
      return @classToStyle lastStyle
    else
      return [0, 0, 0]

  setNextStyle: (elements, id, className) ->
    if (e = elements[id].children).length isnt 0
      e[e.length - 1].setAttribute('nextStyle', className)
    else
      elements[id].setAttribute('nextStyle', className)

  constructElements: (input, delims, elements, id) ->
    element = elements[id]
    for [style, _index, textIndex], index in delims
      innerText = input.substr(textIndex, if (d = delims[index + 1])? then d[1] - textIndex else undefined)
      className = @styleToClass style
      if innerText is ''
        @setNextStyle elements, id, className
        continue
      e = document.createElement 'span'
      element.appendChild e
      e.className = className
      if index is delims.length - 1 and innerText isnt ''
        if (m = ColorRegexEnd.exec(innerText))?
          left = innerText.substr(0, m.index)
          right = innerText.substr(m.index)
          e.setAttribute('endsWithAnsi', right)
          innerText = left
      e.innerText = innerText

  getDelim: (input, elements, id) ->
    lastStyle = @getNextStyle elements, id
    delims = [[lastStyle, 0, 0]]
    while (m = ColorRegex.exec(input))?
      delims.push [@ansiToStyle(m[1]), m.index, m.index + 3 + m[1].length]
    for [style], index in delims
      for s, i in style
        if s is -1
          style[i] = delims[index - 1][0][i]
    return delims

  parseAnsi: (input, elements, id) ->
    input = @getEndsWithAnsi(elements, id) + input
    @constructElements input, @getDelim(input, elements, id), elements, id
