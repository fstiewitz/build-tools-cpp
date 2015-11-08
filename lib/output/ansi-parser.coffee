ColorRegex = /\x1b\[([0-9;]*)m/g
Escape = /\x1b/

module.exports =

  classToStyle: (className) ->
    styles = []
    for style in className.split ' '
      styles.push parseInt(style.substr(1))
    return styles

  ansiToStyle: (ansi) ->
    styles = [-1, -1]
    for style in ansi.split ';'
      if (i = parseInt(style)) >= 30 and i <= 37
        styles[0] = i
      else if i >= 40 and i <= 47
        styles[1] = i
      else if i is 0
        styles = [0, 0]
    return styles

  styleToClass: (styles) ->
    classNames = []
    for style in styles
      classNames.push "a#{style}"
    return classNames.join ' '

  getLastStyle: (elements, id) ->
    lastStyle = (pp = elements[id - 1])?.children[pp.children.length - 1]?.className
    return [0, 0] unless lastStyle?
    lastStyle = nextStyle if (nextStyle = pp?.children[pp.children.length - 1].getAttribute('nextStyle'))? and nextStyle isnt ''
    return @classToStyle lastStyle

  constructElements: (input, delims, elements, id) ->
    element = elements[id]
    for [style, _index, textIndex], index in delims
      innerText = input.substr(textIndex, if (d = delims[index + 1])? then d[1] - textIndex else undefined)
      className = @styleToClass style
      if innerText is ''
        if element.children.length isnt 0
          element.children[element.children.length - 1].setAttribute('nextStyle', className)
          continue
        else
          if (e = elements[id - 1])?
            e.children[e.children.length - 1].setAttribute('nextStyle', className)
            continue
      e = document.createElement 'span'
      element.appendChild e
      e.className = className
      e.innerText = innerText

  getDelim: (input, elements, id) ->
    lastStyle = @getLastStyle elements, id
    delims = [[lastStyle, 0, 0]]
    while (m = ColorRegex.exec(input))?
      delims.push [@ansiToStyle(m[1]), m.index, m.index + 3 + m[1].length]
    for [style], index in delims
      for s, i in style
        if s is -1
          style[i] = delims[index - 1][0][i]
    return delims

  parseAnsi: (input, elements, id) ->
    @constructElements input, @getDelim(input, elements, id), elements, id
