import ../utils/actors_utils_extensions

type
  Buffer*[T] = ref object
    # Public
    len*: int  
    # Private
    cap: int
    pointers_index: int
    elements: seq[T]
    pointers: seq[int]
    pointers_free: seq[int]

using
  self: Buffer

proc `[]`*[T](self, index: int): ptr T =
  result = addr self.elements[self.pointers[index]]

iterator loop*[T](self): int =
  ## Iterates buffer backwards 
  for i in countdown(self.len-1, 0):
    yield i
    

proc newBuffer*[T](size: int): Buffer[T] =
  result = new(Buffer[T])
  result.cap = size-1
  result.elements.setLen(result.cap)
  result.pointers_free.setLen(result.cap)
  result.pointers.setLen(result.cap)
  

proc add*[T](self):ptr T =
  let index = self.len

  if self.len == self.cap:
    self.cap = self.len shl 1
    self.elements.setLen(self.cap)
    self.pointers_free.setLen(self.cap)
    self.pointers.setLen(self.cap)

  inc self.len
  
  if self.pointers_index > 0:
    self.pointers[index] = self.pointers_free[--self.pointers_index]    
  else:
    self.pointers[index] = index
 
  result = addr self.elements[self.pointers[index]]

proc removeAt*[T](self, index: int) =
  inc self.pointers_index
  self.pointers_free[self.pointers_index] = self.pointers[index]
  dec self.len 
  if index < self.len:
    for i in index..self.len:
      swap(self.pointers[i+1],self.pointers[i])
