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