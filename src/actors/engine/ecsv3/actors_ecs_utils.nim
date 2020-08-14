import times
import strformat
import hashes

import actors_ecs_h

#template `@`(arg: untyped):untyped =
#  (entid)

proc binarysearch(this: ptr seq[ent], value: int): int {.discardable, used, inline.} =
  var m : int = -1
  var left = 0
  var right = this[].high
  while left <= right:
      m = (left+right) div 2
      if this[][m].id == value: 
          discard
      if this[][m].id < value:
          left = m + 1
      else:
          right = m - 1
  return m

proc hash*(x: set[uint16]): Hash =
  result = x.hash
  result = !$result