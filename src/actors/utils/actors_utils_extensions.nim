import macros

proc debug_macro*(arg: string): NimNode =
    nnkStmtList.newTree(
        nnkCommand.newTree(
            newIdentNode("echo"),
            newLit(arg)
            )
        )

proc remove*[T](this: var openArray[T], elem: T) =
  this.remove(elem)

proc add_new_delegate*[T](this: var seq[T], arg: T)=
    this.add(arg)
    

proc add_new*[T](this: var seq[T]): ptr T {.inline.} =
    this.add(T())
    addr this[this.high]

proc add_new_ref*[T](this: var seq[T]): var T {.inline.} =
    this.add(T())
    this[this.high]


proc toString*(str: var seq[cchar], len: int = 0): string =
  var lenCalculated = 0
  if len == 0:
    lenCalculated = len(str)
  else:
    lenCalculated = len
  result = newStringOfCap(lenCalculated)
  for i in 0..<lenCalculated:
    add(result,str[i])

template to_uint32*(t: openArray[int]): seq[uint32]= 
  var arg {.inject.} = newSeq[uint32](t.len)
  for i in 0..arg.high:
    arg[i] = (uint32)t[i]    
  arg

template size*[T](t: openArray[T]): cint =
  cint(T.sizeof * t.len) 
