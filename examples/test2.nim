# {.used.}
# {.experimental: "codeReordering".}
# {.experimental: "dynamicBindSym".}
# import actors
# import macros
# import strformat
# import strutils


# type ComponentObject* = object
# type ComponentMotion* = ref object
#   arg*: int

# macro formatComponentPrettyr*(t: typedesc): untyped =
#   let tName = strVal(t)
#   # var source = &("""
#   # template `{tName}Poo`*(self: ent) =
#   #     echo "poo"
#   #     """)
#   var source = &("""
#   template `{tName}Poo`*(self: ent): ptr {tName} =
#       impl_get(self,{tName})
#       """)
       

#   result = parseStmt(source)
  

# template binder*(t: typedesc) {.used.} =
#   var storage = newSeq[t](10)
#   var map = newSeq[int](10)
#   storage[0] = t()
#   storage[1] = t()
#   map[0] = 0
#   map[1] = 0

#   proc impl_get*(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
#       addr storage[map[self.id]]
  
#   formatComponentPrettyr(t)


# binder ComponentMotion


  #result = parseStmt(source)

# var motions* = newSeq[ComponentMotion](12)
# motions[0] = ComponentMotion()
# motions[1] = ComponentMotion()

# template mo*(self: ent): ComponentMotion =
#   motions[self.id]