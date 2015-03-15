d = null
d_l = null
d_c = null
d_d = null

lines = []
last = []
first_run = true
size = 10

updateSize = () ->
  real = size * 13
  height = window.innerHeight - 36
  d.style.height = (if real > height then real else height) + "px"

addLine = () ->
  l = document.createElement "div"
  l.className = "line line-" + lines.length
  lines.push l
  last.push ""
  d_d.appendChild l

removeLine = () ->
  lines.pop()
  last.pop
  d_d.removeChild d_d.lastChild

colorize = (line) ->
  spanize = (type, value) ->
    "<span class='#{type}'>#{value}</span>"

  typize = (value) ->
    return "number" if value.match(/^(-?[0-9]+)$/g) isnt null
    return "register" if value.match(/^(R[0-7]|SP|FP)$/gi) isnt null
    return "builtin" if value.match(/^(CRT|KBD|STDIN|STDOUT|HALT|READ|WRITE|TIME|DATE)$/gi) isnt null
    return "data-command" if value.match(/^(DC|DS|EQU)$/gi) isnt null
    return "command" if value.match( /^(NOP|STORE|LOAD|IN|OUT|ADD|SUB|MUL|DIV|MOD|AND|OR|XOR|SHL|SHR|NOT|SHRA|COMP|JUMP|JNEG|JZER|JPOS|JNNEG|JNZER|JNPOS|JLES|JEQU|JGRE|JNLES|JNEQU|JNGRE|CALL|EXIT|PUSH|POP|PUSHR|POPR|SVC)$/gi) isnt null
    "unknown"

  word = ""
  colorized = ""
  in_comment = false
  for c, i in line
    if c == ";"
      colorized += spanize typize(word), word if word.length > 0
      word = ""
      colorized += spanize "comment", line.substring i
      break
    else if c in ["@", "=", "(", ")"]
      colorized += spanize typize(word), word if word.length > 0
      word = ""
      colorized += spanize "syntax", c
    else if c in [" ", "\t", ","]
      colorized += spanize typize(word), word if word.length > 0
      word = ""
      colorized += c
    else
      word += c
  colorized += spanize typize(word), word if word.length > 0
  word = ""

  return colorized

updateSelected = () ->
  ps = d_c.selectionStart
  pe = d_c.selectionEnd
  cn = 0
  cs = -1
  for c, i in d_c.value
    cs = cn if i == ps
    break if i == pe
    cn++ if c == '\n'
  for el in document.querySelectorAll(".line.selected")
    el.classList.toggle "selected"
  cs = cn if cs is -1
  for i in [cs .. cn]
    document.querySelector(".line-" + i).classList.toggle "selected"

tabby = () ->
  console.log "asdadsdsa"
  ps = d_c.selectionStart
  pe = d_c.selectionEnd
  console.log ps, pe
  if ps is pe
    line = ""
    cn = 0
    for c, i in d_c.value
      break if i is ps
      line += c
      if c is '\n'
        cn++
        line = ""
    whole = d_c.value.split('\n')[cn]
    pos = line.length
    t = []
    t[0] = line
    t[1] = whole.substring(pos)
    num = 0
    if pos % 8 is 0
      num = 8
    else
      while pos % 8 != 0
        num++
        pos++
    for i in [0..num-1]
      t[0] += " "
    wlines = d_c.value.split('\n')
    wlines[cn] = t[0] + t[1]
    d_c.value = wlines.join('\n')
    console.log num

    d_c.focus()
    d_c.setSelectionRange pe + num, ps + num
    d_c.oninput()


window.onload = () ->
  startEditor()

startEditor = () ->
  d = document.querySelector "#editor"
  d_c = document.querySelector "#editor .code"
  d_d = document.querySelector "#editor .display"
  d_l = document.querySelector "#editor .line_numbers"
  updateSize()
  d_c.value = ""

  d_c.onmousedown = d_c.onkeyup = d_c.onmouseup = (evt) ->
    window.setTimeout () ->
      updateSelected()
     , 1

  d_c.onkeydown = (evt) ->
    if evt.keyCode is 9
      evt.preventDefault()
      tabby()
    window.setTimeout () ->
      updateSelected()
     , 1

  d_c.onscroll = (evt) ->
    d_d.scrollTop = d_c.scrollTop
    d_l.scrollTop = d_c.scrollTop

  d_c.oninput = (evt) ->
    code_lines = d_c.value.split "\n"

    while lines.length < code_lines.length
      addLine()
    while lines.length > code_lines.length
      removeLine()

    size = lines.length
    updateSize()

    line_numbers = ""
    for line, ind in lines
      line_numbers += (ind + 1) + " \n"
      code = code_lines[ind]
      if first_run or last[ind].length is 0 or code isnt last[ind] or ind + 1 is lines.length
        line.innerHTML = if code.length > 0 then colorize(code) else "&nbsp;"
        last[ind] = code
    d_l.innerHTML = line_numbers
    first_run = false

  d_c.oninput()