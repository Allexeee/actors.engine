import strutils
import macros
import strformat
import ../pixeye_ecs_h

func binarysearch*(this: ptr seq[eid], value: int): int {.discardable, used, inline.} =
  var m : int = -1
  var left = 0
  var right = this[].high
  while left <= right:
      m = (left+right) div 2
      if this[][m].int == value: 
          return m
      if this[][m].int < value:
          left = m + 1
      else:
          right = m - 1
  return m
func incAge*(age: var int) =
  if age == high(int):
    age = 0
  else: age += 1

proc formatComponentAlias*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toUpperAscii(s[0]) & substr(s, 1)
proc formatComponent*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toLowerAscii(s[0]) & substr(s, 1)
proc formatComponentLong*(s: var string) {.used.}=
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toUpperAscii(s[0]) & substr(s, 1)

template genIndices*(self: var seq[int]) {.used.} =
  self = newSeq[int](ENTS_MAX_SIZE)
  for i in 0..self.high:
    self[i] = ent.nil.id

macro formatComponentPrettyAndLong*(T: typedesc): untyped {.used.}=
  let tName = strVal(T)
  var proc_name = tName  
  proc_name  = toLowerAscii(proc_name[0]) & substr(proc_name, 1)
  formatComponent(proc_name)
  var source = &("""
  template `{proc_name}`*(self: ent): ptr {tName} =
      impl_get(self,{tName})
      """)
  result = parseStmt(source)
macro formatComponentPrettyAndLongEid*(T: typedesc): untyped {.used.}=
  let tName = strVal(T)
  var proc_name = tName  
  proc_name  = toLowerAscii(proc_name[0]) & substr(proc_name, 1)
  formatComponent(proc_name)
  var source = &("""
  template `{proc_name}`*(self: eid): ptr {tName} =
      impl_get(self,{tName})
      """)
  result = parseStmt(source)
macro formatComponentPretty*(t: typedesc): untyped {.used.}=
  let tName = strVal(t)
  var proc_name = tName  
  formatComponent(proc_name)
  var source = ""
  source = &("""
    template `{proc_name}`*(self: ent): ptr {tName} =
        impl_get(self,{tName})
        """)

  result = parseStmt(source)
macro formatComponentPrettyEid*(t: typedesc): untyped {.used.}=
  let tName = strVal(t)
  var proc_name = tName  
  formatComponent(proc_name)
  var source = ""
  source = &("""
    template `{proc_name}`*(self: eid): ptr {tName} =
        impl_get(self,{tName})
        """)

  result = parseStmt(source)

proc getref*[T](self: var seq[T]) : var T {.inline.} =
  self.add(T())
  self[self.high]

proc getptr*[T](self: var seq[T]) : ptr T {.inline.} =
  self.add(T())
  self[self.high].addr