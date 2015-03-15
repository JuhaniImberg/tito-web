BinaryCommand = require("./binary_command.coffee").BinaryCommand
commands = require("../data/commands.coffee").commands
registers = require("../data/registers.coffee").registers
symbols = require("../data/symbols.coffee").symbols

class IR
  constructor: () ->
    @binary_code = []
    @ir_code = []
    @data = []
    @symbol_table = {}

  add_equ: (name, val) ->
    @symbol_table[name] = [false, val]

  add_dc: (name, val) ->
    pos = @data.length
    @data.push val
    @symbol_table[name] = [true, pos]

  add_ds: (name, val) ->
    pos = @data.length
    @data.push(0) for i in [1 .. val]
    @symbol_table[name] = [true, pos]

  add_label: (name, row) ->
    @symbol_table[name] = [false, row]

  add_line: (code) ->
    @ir_code.push code

  generate: () ->
    for line, index in @ir_code
      gen = new BinaryCommand()
      @binary_code.push gen

      gen.set "op", commands[line.op]
      gen.set "m", ["=", null, "@"].indexOf line.m

      if line.op == "STORE" and gen.get("m") == 2
        gen.set "m", 1
      else if line.op in ["STORE", "CALL"] or line.op[0] == "J"
        gen.set "m", 0

      gen.set "rj", registers[line.rj]
      gen.set "ri", registers[line.ri]

      if line.addr of symbols and not (line.addr of @symbol_table)
        @symbol_table[line.addr] = [false, symbols[line.addr]]

      if line.addr of registers
        gen.set "ri", registers[line.addr]
        gen.set "m", 0
      else if line.addr of @symbol_table
        sym = @symbol_table[line.addr]
        gen.set "addr", if sym[0] then sym[1] + @ir_code.length else sym[1]
      else if gen.get("m") == 0
        gen.set "addr", parseInt line.addr
      else
        throw "Malformed address #{line.line_number}: #{line.raw}"

  get_symbols: () ->
    sym = {}
    sym[key] = (if value[0] then value[1] + @ir_code.length else value[1]) for key, value of @symbol_table
    sym

  binary: () ->
    code_len = @ir_code.length
    data_len = @data.length
    section = (thing) -> "___#{thing}___\n"

    bin = section "b91"
    bin += section "code"

    bin += "0 #{code_len - 1}\n"
    bin += "#{x.binary()}\n" for x in @binary_code

    bin += section "data"

    bin += "#{code_len} #{code_len + data_len - 1}\n"
    bin += "#{x}\n" for x in @data

    bin += section "symboltable"

    bin += "#{key.toLowerCase()} #{if value[0] then value[1] + code_len else value[1]}\n" for key, value of @symbol_table

    bin += section "end"
    return bin


module.exports.IR = IR