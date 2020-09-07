import macros
{.used.}


#converter floatToInt*(f: float): int = f.int
#converter float64ToInt*(f: float64): int = f.int
#converter intToFloat*(f: int): float = f.float

template `!`*(arg: bool): bool =
  var result : bool
  if arg == true: result = false
  else: result = true
  result

#@collections
proc push*[T](self: var seq[T], elem: T) {.inline.} =
  self.add(elem)

proc getref*[T](self: var seq[T]) : var T {.inline.} =
  self.add(T())
  self[self.high]

# proc push_addr*[T](self: var seq[T], grow_size: int): ptr T {.inline.} =
#   self.setLen(self.len+grow_size)
#   addr self[self.high]

proc push_addr*[T](self: var seq[T]): ptr T =
  self.add(T())
  addr self[self.high]

template usePtr*[T]() =
  template `+`(p: ptr T, off: SomeInteger ): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% int(off) * sizeof(p[]))
  
  template `+=`(p: ptr T, off: SomeInteger ) =
    p = p + off
  
  template `-`(p: ptr T, off: SomeInteger): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) -% int(off) * sizeof(p[]))
  
  template `-=`(p: ptr T, off: SomeInteger ) =
    p = p - int(off)
  
  template `[]`(p: ptr T, off: SomeInteger ): T =
    (p + int(off))[]
  
  template `[]=`(p: ptr T, off: SomeInteger , val: T) =
    (p + off)[] = val

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

proc inc*[T](this: var seq[T]): ptr T {.inline.} =
    this.add(T())
    addr this[this.high]




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

#template csizeOf*[T]()