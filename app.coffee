###
  Copyright (C) 2015 Juhani Imberg

  This file is part of tito-web.

  tito-web is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  tito-web is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with tito-web. If not, see <http://www.gnu.org/licenses/>.
###

Parser = require("./compiler/parser.coffee").Parser
VM = require("./vm/vm.coffee").VM
require("./editor.coffee")

parser = new Parser()
vm = null

clearOfChildren = (target) ->
  while target.lastChild
    target.removeChild target.lastChild

update_memory = (newmem, explains, selected) ->
  target = document.querySelector "#memory tbody"
  clearOfChildren target

  for row, ind in newmem
    tr = document.createElement "tr"
    tr.className = "memory-line memory-line-#{ind}"
    if ind is selected
      tr.className += " memory-line-selected"

    ind_td = document.createElement "td"
    ind_td.innerHTML = ind
    value_td = document.createElement "td"
    value_td.innerHTML = row
    explanation_td = document.createElement "td"
    explanation_td.innerHTML = explains[ind]

    tr.appendChild ind_td
    tr.appendChild value_td
    tr.appendChild explanation_td

    target.appendChild tr

update_registers = (order, registers) ->
  target = document.querySelector "#registers tbody"
  clearOfChildren target
  for name, ind in order
    register = registers[ind]
    tr = document.createElement "tr"

    register_td = document.createElement "td"
    register_td.innerHTML = name
    value_td = document.createElement "td"
    value_td.innerHTML = register

    tr.appendChild register_td
    tr.appendChild value_td

    target.appendChild tr

update_symbols = (symbols) ->
  target = document.querySelector "#symbols tbody"
  clearOfChildren target

  for key, val of symbols
    tr = document.createElement "tr"

    ind_td = document.createElement "td"
    ind_td.innerHTML = key
    value_td = document.createElement "td"
    value_td.innerHTML = val

    tr.appendChild ind_td
    tr.appendChild value_td

    target.appendChild tr

compile = () ->
    code = document.querySelector("#editor .code").value
    ir = parser.parse code
    ir.generate()

    if vm isnt null
      vm.removeAllListeners()

    vm = new VM()
    vm.load ir.binary()
    vm.input = document.querySelector("#input").value.split(",").map((x) -> parseInt(x.trim()))

    output_f = document.querySelector "#output"
    output_f.value = ""

    update_memory vm.memory, vm.explains, -1
    update_symbols vm.symbols
    update_registers ["R0", "R1", "R2", "R3", "R4", "R5", "SP", "FP"], vm.registers

    pos = -1

    vm.on "prestep", (v) ->
      pos = v.position

    vm.on "step", (v) ->
      output_f.value = v.output.join ", "
      update_memory v.memory, v.explains, pos
      update_symbols v.symbols
      update_registers ["R0", "R1", "R2", "R3", "R4", "R5", "SP", "FP"], v.registers

step = () ->
  vm.step() if vm

step_all = () ->
  vm.step_all() if vm

window.addEventListener "load", () ->

  document.querySelector("#compile").onclick = () ->
    compile()

  document.querySelector("#step").onclick = () ->
    step()

  document.querySelector("#step-all").onclick = () ->
    step_all()

  document.querySelector("#input").oninput = (evt) ->
    vm.input = evt.target.value.split(",").map((x) -> parseInt(x.trim())) if vm isnt null

  document.addEventListener "keydown", (evt) ->
    if evt.ctrlKey and evt.keyCode is 69
      compile()
      evt.preventDefault()
    else if evt.altKey and evt.keyCode is 13
      step()
    else if evt.ctrlKey and evt.keyCode is 13
      step_all()
