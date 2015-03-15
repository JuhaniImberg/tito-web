module.exports.commands =
  NOP: 0
  STORE: 1
  LOAD: 2
  IN: 3
  OUT: 4
  ADD: 17
  SUB: 18
  MUL: 19
  DIV: 20
  MOD: 21
  AND: 22
  OR: 23
  XOR: 24
  SHL: 25
  SHR: 26
  NOT: 27
  SHRA: 28
  COMP: 31
  JUMP: 32
  JNEG: 33
  JZER: 34
  JPOS: 35
  JNNEG: 36
  JNZER: 37
  JNPOS: 38
  JLES: 39
  JEQU: 40
  JGRE: 41
  JNLES: 42
  JNEQU: 43
  JNGRE: 44
  CALL: 49
  EXIT: 50
  PUSH: 51
  POP: 52
  PUSHR: 53
  POPR: 54
  SVC: 112

module.exports.reverse_commands = {}
module.exports.reverse_commands[value] = key for key, value of module.exports.commands