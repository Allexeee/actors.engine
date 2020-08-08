import actors
type Poo* = object
  arg*: int

var
  rawMem = alloc0(600*sizeof(Poo))
  byteUA = cast[ptr UncheckedArray[Poo]](rawMem)

var a  : array[600,Poo]
var a2 : array[10,Poo]
var indexes : array[10,int]
var indexesGapped : array[10,int]
for i in 0..9:
  indexes[i] = i
  indexesGapped[i] = i*25

indexesGapped[8] = 311
indexesGapped[9] = 578
#var pp = addr byteUA[1]
#pp[].arg = 0
#var v = byteUA[100].addr[].arg
var arg = 0
profile.start "Gaps":
  for ii in 0..1000000:
    for i in indexesGapped:
      arg = byteUA[i].arg
# profile.start "NoGaps":
#   for ii in 0..1000000:
#     for i in indexes:
#       arg = a[i].arg

profile.log