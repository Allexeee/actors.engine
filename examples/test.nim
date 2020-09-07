type Element = object
  arg: int


# proc `+`[T](a: ptr T, b: int): ptr T =
#     if b >= 0:
#         cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
#     else:
#         cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

# template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)

var elements {.noinit.} : array[1000,Element]
elements[2].arg = 1000
# var mem = alloc0(1000*sizeof(Element))

# var elements = cast[ptr UncheckedArray[Element]](mem)
# var el = elements[0].addr

# el = el + 1
# el = el + 1

# elements[2].arg = 1000
# echo sizeof(el)
# #echo el[2].type

# dealloc(mem)