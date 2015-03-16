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

BinaryCommand = require("../compiler/binary_command.coffee").BinaryCommand
reverse_commands = require("../data/commands.coffee").reverse_commands
events = require "events"

class VM extends events.EventEmitter
  constructor: () ->
    @memory = []
    @explains = []
    @commands = []
    @symbols = {}
    @registers = [0, 0, 0, 0, 0, 0, 0, 0]
    @position = 0

    @cmp = 0

    @input_pos = 0
    @input = []
    @output = []

    @done = false

  load: (code) ->
    lines = code.split "\n"

    [code_start, code_end] = lines[2].split(" ").map (x) -> parseInt x

    for i in [code_start .. code_end]
      @memory.push parseInt lines[3 + i]

    [data_start, data_end] = lines[5 + code_end].split(" ").map (x) -> parseInt x

    for i in [data_start .. data_end]
      @memory.push parseInt lines[5 + i]

    for i in [7 + data_end .. lines.length - 3]
      [key, val] = lines[i].split " "
      @symbols[key] = parseInt val

    @registers[6] = data_end
    @registers[7] = code_end

    for line, ind in @memory
      cmd = new BinaryCommand()
      register_ind = ["R0", "R1", "R2", "R3", "R4", "R5", "SP", "FP"]
      cmd.fields["addr"].allow_negative = true
      cmd.load line
      cmd_op = reverse_commands[cmd.get "op"]
      cmd_rj = register_ind[cmd.get("rj")]
      cmd_ri = register_ind[cmd.get("ri")]
      cmd_addr = cmd.get "addr"
      cmd_m = ["=", "", "@"][cmd.get("m")]
      @explains.push "#{cmd_op} #{cmd_rj}, #{cmd_m}#{cmd_addr}(#{cmd_ri})"


  get_addr: (command, override=null) ->
    m = if override is null then command.get("m") else override
    addr = command.get "addr"
    ri = @registers[command.get "ri"]
    addr += ri
    return switch m
      when 0 then addr
      when 1 then @memory[addr]
      when 2 then @memory[@memory[addr]]

  step_all: () ->
    while @step() is true
      continue

  step: () ->
    return false if @done
    @emit "prestep", this
    ret = false
    try
      cmd = new BinaryCommand()
      cmd.fields["addr"].allow_negative = true
      cmd.load @memory[@position]
      cmd_name = reverse_commands[cmd.get "op"]
      fn_name = "c_" + cmd_name.toLowerCase()
      ret = this[fn_name](cmd)
    catch e
      @done = true
      if e isnt "halt"
        alert e
    if ret is false
      @position++
    @emit "step", this
    return true

  c_nop: (command) ->

  c_store: (command) ->
    @memory[@get_addr command] = @registers[command.get "rj"]
    false

  c_load: (command) ->
    @registers[command.get "rj"] = @get_addr command
    false

  c_in: (command) ->
    @registers[command.get "rj"] = @input[@input_pos++]
    false

  c_out: (command) ->
    @output.push @registers[command.get "rj"]
    false

  c_add: (command) ->
    @registers[command.get "rj"] += @get_addr command
    false

  c_sub: (command) ->
    @registers[command.get "rj"] -= @get_addr command
    false

  c_mul: (command) ->
    @registers[command.get "rj"] *= @get_addr command
    false

  c_div: (command) ->
    @registers[command.get "rj"] /= @get_addr command
    false

  c_mod: (command) ->
    @registers[command.get "rj"] %= @get_addr command
    false

  c_and: (command) ->
    @registers[command.get "rj"] |= @get_addr command
    false

  c_xor: (command) ->
    @registers[command.get "rj"] ^= @get_addr command
    false

  c_shl: (command) ->
    @registers[command.get "rj"] <<= @get_addr command
    false

  c_shr: (command) ->
    @registers[command.get "rj"] >>>= @get_addr command
    false

  c_shra: (command) ->
    @registers[command.get "rj"] >>= @get_addr command
    false

  c_not: (command) ->
    @registers[command.get "rj"] ^= 0xffff
    false

  c_comp: (command) ->
    @cmp = @registers[command.get "rj"] - @get_addr command
    false

  c_jump: (command) ->
    @position = @get_addr command
    true

  c_jneg: (command) ->
    if @registers[command.get "rj"] < 0
      @position = @get_addr command
      return true
    false

  c_jzer: (command) ->
    if @registers[command.get "rj"] is 0
      @position = @get_addr command
      return true
    false

  c_jpos: (command) ->
    if @registers[command.get "rj"] > 0
      @position = @get_addr command
      return true
    false

  c_jnneg: (command) ->
    if @registers[command.get "rj"] >= 0
      @position = @get_addr command
      return true
    false

  c_jnzer: (command) ->
    if @registers[command.get "rj"] isnt 0
      @position = @get_addr command
      return true
    false

  c_jnpos: (command) ->
    if @registers[command.get "rj"] <= 0
      @position = @get_addr command
      return true
    false

  c_jles: (command) ->
    if self.cmp < 0
      @position = @get_addr(command, 0)
      return true
    false

  c_jequ: (command) ->
    if self.cmp is 0
      @position = @get_addr(command, 0)
      return true
    false

  c_jgre: (command) ->
    if self.cmp > 0
      @position = @get_addr(command, 0)
      return true
    false

  c_jnles: (command) ->
    if self.cmp >= 0
      @position = @get_addr(command, 0)
      return true
    false

  c_jnequ: (command) ->
    if self.cmp isnt 0
      @position = @get_addr(command, 0)
      return true
    false

  c_jngre: (command) ->
    if self.cmp <= 0
      @position = @get_addr(command, 0)
      return true
    false

  c_call: (command) ->
    @memory.push @position + 1
    @memory.push @registers[7]
    @position = @get_addr command
    @registers[7] = (@registers[command.get "rj"] += 2)
    true

  c_exit: (command) ->
    sp = @registers[command.get "rj"]
    @registers[7] = @memory[sp]
    @position = @memory[sp - 1]
    @registers[command.get "rj"] = sp - 2 - @get_addr command
    true

  c_push: (command) ->
    @memory.push @get_addr command
    @registers[command.get "rj"]++
    false

  c_pop: (command) ->
    @registers[command.get "ri"] = @memory[@registers[command.get "rj"]]
    @registers[command.get "rj"]--
    false

  c_svc: (command) ->
    switch @get_addr command
      when 11 then throw "halt"
    false

module.exports.VM = VM
