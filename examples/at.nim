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
#var players = game.group(CompA)

proc makePlayer*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  #result.get CompA


var amount = 1_000_000
var steps = 60*3600


profile.start "creating":
  for i in 0..<amount:
    var e = game.entity()
   # e.get CompA

# profile.start "execute":
#   game.ecs.execute()


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
