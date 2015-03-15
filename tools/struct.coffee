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