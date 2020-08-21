import actors
import macros

type SegA {.final.} = object
  arg: int
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
app.add CompC
app.add CompD
app.add SegA

var ecs = game.ecs

for x in 0..<1_000_000:
  profile.start "init": 
    ecs.entity:
      let ca = e.get CompA

for x in 0..<60:
  #profile.start "query3": 
  #   for ca in query3(CompA):
  #     ca.arg += 1
  # profile.start "query2": 
  #   for ca in query2(CompA):
  #     ca.arg += 1
  profile.start "query": 
    for ca in query(CompA):
      ca.arg += 1
profile.log
# var v : ptr CompA

# #var players = ecs.group(CompA)
# var eee = newSeq[ent]()
# for x in 0..<1000000:
#   profile.start "create":
#     ecs.entity:
#       let ca = e.get CompA
#       eee.add(e)
#   profile.start "iter":
#     v = eee[x].compA

#profile.log

# for x in 0..<(60*3600):
#   # profile.start "cached":
#   #   for e in players:
#   #     let ca = e.compA
#   #     ca.arg += 1

#   # profile.start "'dynamic'":
#   #   for e in game.group(CompA):
#   #     let ca = e.compA
#   #     ca.arg += 1
#   profile.start "query":
#     for ca in ecs.query(CompA):
#       ca.arg += 1
      
  # profile.start "query2":
  #   for ca in ecs.query(CompA):
  #     ca.arg += 1





