import sets
import hashes

var mask = {1,2}
var mask2 = {1,2}

echo mask
echo mask2
#var incl = {1}
#var excl = {-2}

#var incl2 = {2,-1}
#var excl2 = {4,3}

# var mask = (incl+excl).hash 
# var mask2 = incl.hash + excl.hash
# var mask3 = (incl2+excl2).hash 
# var mask4 = incl2.hash + excl2.hash
# echo mask
# echo mask2
# echo mask3
# echo mask4
# import actors
# import macros
# import sets
# import hashes
# import tables

# var incl = @[0,50]
# var incl2 = @[0,15]
# var incl3 = {15,0}
# var incl4 = {2,5}

# type CompA {.final.} = object
#   arg: int
# type CompB {.final.} = object
#   arg: int
# type CompC {.final.} = object
#   arg: int
# type CompD {.final.} = object
#   arg: int
# type CompF {.final.} = object
#   arg: int

# var game  = app.addLayer(); game.use()

# app.add CompA
# app.add CompB

# type Group = ref object
#   id: int

# var beatles = initTable[int, int]()
# beatles.add(incl.hash,0)
# beatles.add(incl2.hash, 1)

# var hhh = incl4.hash
# var hhh2 = incl3.hash
# var hhhh = (incl3+incl4).hash
# echo hhh
# echo hhh2
# echo hhhh


# proc qutest*(T,Y: typedesc): int =
#     let st1 = T.getStorage()
#     let st2 = Y.getStorage()
#     var smallest : CompStorageBase = st1; smallest.filterid = 0; result = 0
#     if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1; result = 1

# # iterator query*(T,Y: typedesc): (ptr T, ptr Y) {.inline.} =
  
# #   block iteration:
# #     for ii in excluded_storages:
# #       if ii.entities.len > 0: break iteration
    
# #     let st1 = T.getStorage()
# #     let st2 = Y.getStorage()
# #     var smallest : CompStorageBase = st1; smallest.filterid = 0
# #     if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1


# var gg : int

# # for x in 0..<1000000:
# #   profile.start "hash":
# #     gg = beatles[incl2.hash]
# #   profile.start "queru":
# #     gg = qutest(CompA,CompB)

# # profile.log
# # var s : set[uint16]
# # echo s.sizeof
# # var incl = {0,50,5}
# # var excl = {1,15}

# # echo $incl

# # type CompA = object
# #   arg*: int

# # iterator poo(T: typedesc): ptr T {.closure.} =
#   block iteration:
#    let st1 = T.getStorage()
#    let max = st1.comps.high
#    for i in 0..max:
#      yield st1.comps[i].addr

# var iter = poo


# for ca in iter(CompA):
#   echo ca
  #ca.arg += 1
  #UncheckedArray[int]


# type Storage = seq[int]

# var st = newSeq[Storage](90)
# var sig = newSeq[int]()

# for i in 0..st.high:
#   st[i] = newSeq[int](6)
#   if i == 0 or i == 3 or i == 10:
#     st[i][1] = 10

# sig.add(0)
# sig.add(3)
# sig.add(10)
# var v = 0
# for x in 0..<100000:
#   profile.start "sig":
#     for i in sig:
#       if st[i][1] == 10:
#         v += 1
#   profile.start "all":
#     for i in st:
#       if i[1] == 10:
#         v += 1

# echo v
# profile.log