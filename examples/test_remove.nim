import actors
import random

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int
type CompD = object
  arg: int
type CompF = object
  arg: int

app.add CompA
app.add CompB
app.add CompC
app.add CompD
app.add CompF

var game = app.addLayer()
var players = game.group(CompA,CompB,CompC,CompD,CompF)


proc mk_player*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA
  result.get CompB
  result.get CompC
  result.get CompD
  result.get CompF

proc mk_ca*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA


var randoms = newSeq[int](1000)

for i in 0..999:
  randoms[i] = i

for i in 5000..7999:
  randoms.add(i)


randomize(getTime().toUnix)
randoms.shuffle()

for i in 0..<10000:
  game.mk_player()

game.ecs.execute()
# [07:52:13] Benchmark:
# Time elapsed for removing v1: 0.035000000 x4000 removes 9% slower
profile.start "removing v1":
  for i in randoms:
    players.entities[i].remove CompA
  
  game.ecs.execute()
profile.log

# [07:49:23] Benchmark:
# Time elapsed for removing v2: 0.032000000 x4000 removes
# profile.start "removing v2":
#   for i in randoms:
#     players.entities[i].remove CompA
  
#   game.ecs.execute2()
# profile.log

echo players.entities.len