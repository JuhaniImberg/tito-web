IR = require("./ir.coffee").IR
IRCommand = require("./ir_command.coffee").IRCommand

class Parser
  constructor: () ->
  parse: (code) ->
    ir = new IR()
    code_lines = 0
    for line, line_number in code.split "\n"
      line = line.split(";")[0] # asd
      tokens = line.split /[ \t,]/

      tokens = tokens.filter (x) -> x.length > 0
      tokens = (x.toUpperCase() for x in tokens)
      tokens = tokens.filter (x) -> x.length > 0
      if tokens.length is 0
        continue
      if @data_command ir, tokens
        continue
      else if @command ir, line_number, line, code_lines, tokens
        code_lines++
      else
        throw "Malformed line #{line_numer}: #{line}"
    ir

  command: (ir, line_number, line, code_lines, tokens) ->
    line = new IRCommand line_number, line, tokens
    ir.add_line line
    if line.label isnt null
      ir.add_label line.label, code_lines
    line.op isnt null

  data_command: (ir, tokens) ->
    return false if tokens.length is not 3
    fn = switch tokens[1]
      when "EQU" then "add_equ"
      when "DC" then "add_dc"
      when "DS" then "add_ds"
      else null
    if fn isnt null
      ir[fn](tokens[0], parseInt(tokens[2]))
      return true
    return false

module.exports.Parser = Parser