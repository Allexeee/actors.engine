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

app.add CompA
app.add CompB
app.add CompC
app.add CompD
app.add CompF

var game = app.addLayer()
var gr_abc = game.group(CompA,CompB,CompC,CompD)
var gr_ab = game.group(CompA,CompB)
var gr_a = game.group(CompA)

proc make_abc*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA
  result.get CompB
  result.get CompC
 
proc make_ab*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()
  result.get CompA
  result.get CompB

for i in 0..<5000:
  game.make_abc()

game.ecs.execute()


var steps = 60*3600

for x in 0..<steps:
  profile.start "q2":
    exclude CompB,CompC
    for ca in query(CompA):
      ca.arg.inc

echo gr_a[0].ca.arg
 
profile.log
