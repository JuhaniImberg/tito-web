commands = require "../data/commands.coffee"
                     .commands

class IRCommand
  constructor: (@line_number, @raw, @tokens) ->
    @label = null
    @op = null
    @rj = null
    @m = null
    @ri = null
    @addr = null

    tokens = @tokens

    i = 0

    @label = tokens[i++] if tokens[i] not of commands
    @op = tokens[i++]

    return if @op == "NOP"

    @rj = tokens[i++] if @op != "JUMP"

    if tokens[i][0] in ["@", "="]
      @m = tokens[i][0]
      tokens[i] = tokens[i].substring 1
    if "(" in tokens[i]
      @ri = tokens[i].split("(")[1].split(")")[0]
      @addr = tokens[i].split(")")[0]
    else
      @addr = tokens[i]
    i += 1

    if i < tokens.length and "(" in tokens[i]
      @ri = tokens[i].split("(")[1].split(")")[0]

module.exports.IRCommand = IRCommand