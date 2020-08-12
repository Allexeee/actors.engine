import strutils
import macros
import strformat


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

# macro formatester*(t: typedesc): untyped {.used.} =
#   let tName = strVal(t)
#   var proc_name = tName  
#   formatComponent(proc_name)
#   var source = ""
#   source = &("""
#     template getComper*(_:{tName}, arg: untyped): untyped =
#       var {proc_name} = storage.comps.addr
#         """)

#   result = parseStmt(source)