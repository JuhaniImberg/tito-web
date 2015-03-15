Struct = require "../tools/struct.coffee"
                   .Struct

class BinaryCommand extends Struct
  constructor: () ->
    super [["op", 8],
           ["rj", 3],
           ["m", 2],
           ["ri", 3],
           ["addr", 16]]

module.exports.BinaryCommand = BinaryCommand
