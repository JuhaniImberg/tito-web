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

class Field
  constructor: (@size) ->
    @value = 0
    @allow_negative = false

  set: (value) ->
    if Math.abs(value) > 2 ** @size - 1
      throw "Struct overflow"
    @value = value

  get: (offset) ->
    value = @value
    if value < 0
      value += 1
      value *= -1
      value ^= (2 ** @size) - 1
    return value << offset

  load: (value) ->
    if (value >> (@size - 1)) == 1 and @allow_negative
      value ^= (2 ** @size) - 1
      value += 1
      value *= -1
    @set value

class Struct
  constructor: (fields) ->
    fields.reverse()
    @order = (x[0] for x in fields)
    @fields = {}
    fields.map (x) => @fields[x[0]] = new Field(x[1])
    @size = fields.reduce (t, s) -> t + s[1]

  set: (name, val) ->
    @fields[name].set(val)

  get: (name) ->
    @fields[name].value

  load: (num) ->
    offset = 0
    for key in @order
      field = @fields[key]
      mask = ((2 ** field.size) - 1) << offset
      val = (num & mask) >> offset
      field.load val
      offset += field.size

  binary: () ->
    val = 0
    offset = 0
    for key in @order
      field = @fields[key]
      val |= field.get offset
      offset += field.size
    return val.toString()

module.exports =
  Struct: Struct
  Field: Field