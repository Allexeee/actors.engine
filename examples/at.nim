import actors

# const SIZE = 1_000_000
# type ent = tuple[id: int,age: int]

# type EntityMeta* {.packed.} = object
#     layer*            : int
#     childs*           : seq[ent]
#     parent*           : ent
#     alive*            : bool
#     age*              : int
#     signature*        : seq[uint8]
#     signature_groups* : seq[uint8] # what groups are already used
#     dirty*            : bool

# var s = newSeq[ent](SIZE)
# var s2 = newSeq[EntityMeta](SIZE)
# echo EntityMeta.sizeof


# import random
# const SIZE = 1_000_000
# type ent = tuple[id: int,age: int]

# var s = newSeq[ent](SIZE)


type CompA {.final.} = object
  arg: int
type CompB {.final.} = object
  arg: int
type CompC {.final.} = object
  arg: int
type CompD {.final.} = object
  arg: int
type CompF {.final.} = object
  arg: int



var game  = app.addLayer(); game.use()

app.add CompA
app.add CompB

var players = game.group(CompA)

proc makePlayer*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  #result.get CompA


# var amount = 1000000
# var steps = 60*3600

# var h = (amount / 50).int

# profile.start "cc":
#   for i in 0..<h:
#      var e = game.entity()
#      e.get CompA
#      e.build()

# # echo players.len
# game.ecs.kill()
# # echo players.len
# profile.start "xx":
#   for i in 0..<h:
#     var e = game.entity2()
#     e.get CompA
#   #discard
#   game.ecs.execute2()

type eee = tuple[i: int, v: int]

var entss = newSeq[eee]()
var available = 0
entss.add (0,0)
entss.add (1,0)
entss.add (2,0)
entss.add (3,0)
entss.add (4,0)
entss.add (5,0)
entss.add (6,0)
entss.add (7,0)
entss.add (8,0)
entss.add (9,0)

var eeee = entss[4]

proc ekill(id:int) =
  available += 1
  system.swap(entss[id],entss[entss.len-available])
  entss[id].v += 1
proc ekill(id:eee) =
  available += 1
  system.swap(entss[id.i],entss[entss.len-available])
  entss[id.i].v += 1
proc eAdd(): eee {.discardable.} =
  if available>0:
    let e1 = entss[entss.len-available].addr
    #echo e1.i, "opas"
    let e2 = entss[e1.i].addr
    let v = e2.v
    e2.v = e1.v
    e1.v = v
    #let v = entss[entss.high].v
    #available
    result = entss[e2.i]
    echo result.i, "dd"
    #result.v = entss[result.i].v
    system.swap(entss[entss.len-available],entss[result.i])
    available -= 1
  #available += 1
  #system.swap(entss[id],entss[entss.high])
  #entss[id].v += 1


ekill(9)
ekill(8)
ekill(7)
ekill(6)
ekill(5)
ekill(4)
ekill(3)
ekill(2)
ekill(1)
ekill(0)

echo entss

var e1 = eAdd()

echo entss

echo e1.v == entss[e1.i].v

e1.ekill()

echo e1.v == entss[e1.i].v

echo entss

var e2 = eAdd()
var e3 = eAdd()
var e4 = eAdd()
eAdd()
eAdd()
eAdd()
#echo e1.i, "-__-", e2.i


echo entss

e3.ekill()
e4.ekill()

echo entss
# echo eeee.v == entss[4].v

# ekill(4)

# echo eeee.v == entss[4].v

# echo entss

# eeee = eAdd()

# echo eeee.v == entss[4].v

# echo entss



  #system.swap(entss[id],entss[id])
#entss.add()

# 0  1 2 3 4 5 6 7 8 9 10
# 0  x 2 3 4 5 6 7 8 9 10
# 0 10|1 2 3 4 5 6 7 8 9 1|0
# 0 10   2 x 4 5 6 7 8 9 1
# 0 10   2 9 4 5 6 7 8 3|0 1|0

#available : 1



# game.ecs.kill()
# # echo players.len
# profile.start "ff":
#   for i in 0..<h:
#     var e = game.entity2()
#     e.get CompA
#   #discard
#   game.ecs.execute2()
echo players.len
# profile.start "execute":
#   game.ecs.execute()
#echo players.len

# profile.start "kill":
#   game.ecs.kill()
#Time elapsed for creating: 0.037000000 seconds
#0.004000000 a
#0.017000000 a
#0.065000000 a
#0.001000000 a
#0.004033 entt
#0.018886 flecs

# for ca in query(CompA):
#   ca.arg += 1
#   echo ca.arg
#profile.start "execution":
#  game.ecs.execute()


# profile.start "query":
#   for x in 0..<steps:
#     for ca in query(CompA):
#       ca.arg += 1

profile.log
echo GC_getStatistics()
