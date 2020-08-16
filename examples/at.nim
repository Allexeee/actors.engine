import actors
import random

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

var players = game.group(CompA)

proc makePlayer*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA


var amount = 5000
var steps = 60*3600

for i in 0..<amount:
  game.makePlayer()

game.ecs.execute()

profile.start "query":
  for x in 0..<steps:
    for ca in query(CompA):
      ca.arg += 1

profile.log

