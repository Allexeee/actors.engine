import actors

import tables

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

#Time elapsed for cc: 0.015000000 seconds
#Profile INIT took 0.018861400 seconds to complete over 1 iteration, averaging 0.018861400 seconds per call
#Profile INIT took 0.019074100 seconds to complete over 1 iteration, averaging 0.019074100 seconds per call
#Profile INIT took 0.022173000 seconds to complete over 1 iteration, averaging 0.022173000 seconds per call
var game  = app.addLayer(); game.use()

app.add CompA
app.add CompB
app.add CompC
app.add CompD
app.add SegA

var players = game.group(CompA)
# var player = game.entity:
#   let ca = e.get CompA

for i in 0..<4:
  discard game.entity:
    let ca = e.get CompA

echo players.len

for e,ca in query(Ent,CompA):
  e.remove CompA


echo players.len
# game.entity:
#   let ca = e.get CompA
# for x in 0..<500000:
#     profile.start "a":
#         game.entity ee:
#           let ca = e.get CompA
#           let cb = e.get CompB
#           ca.arg = 0; cb.arg = 1;
        
# profile.log
      #let ca = e.get CompA



# game.entity player:
#   let ca = e.get CompA
#   let cb = e.get CompB


# echo player
# echo dd

# proc makePlayer*(layer: LayerId): ent {.discardable.} =
#   result = layer.entity()
#   result.get CompA
#   result.get CompB
#   #result.get CompC
#   #result.get CompD


# proc makeAB*(layer: LayerId): ent {.discardable.} =
#   result = layer.entity()
#   result.get CompB
#   result.get CompD
#   #ents.add result

# proc makeAC*(layer: LayerId): ent {.discardable.} =
#   result = layer.entity()
#   result.get CompA
#   result.get CompB
# for i in 0..<3000:
#   game.makeAB()
#   game.makePlayer()
#   game.makeAC()

# game.ecs.execute()

# var ticks = 60*3600
# var c = 0;
# for x in 0..<ticks:
#   profile.start "Q": 
#     for e,ca in query(Ent,CompA):
#       ca.arg+=1; #cb.arg+=1

#   profile.start "G": 
#     for e in abs:
#       let ca = e.ca

#       ca.arg+=1; #cb.arg+=1

# #log c, abs.len
# profile.log
# profile.start "b":
#   for x in 0..<ticks:
#     exclude(CompC)
#     for e in queryTest(CompA,CompB):
#       let ca = e.compA
#       let cb = e.compB
#       ca.arg+=1;cb.arg+=1
# profile.log
  #result.get CompC
  #ents.add result

# for i in 0..<3000:
#   game.makePlayer()
#   game.makeAB()
#   game.makeAC()

# game.ecs.execute()

# var ticks = 60*3600
# #echo abs.len
# profile.start "b":
#   for x in 0..<ticks:
#     for e in gquery(abs):
#       let ca = e.ca
#       let cb = e.cb
#       let cc = e.cc

#       ca.arg+=1
#       cb.arg+=1
#       cc.arg+=1

# profile.start "q":
#   for x in 0..<ticks:
#       for ca,cb,cc in queryf(CompA,CompB,CompC):
#         ca.arg+=1; cb.arg+=1; cc.arg+=1
  

#log c
#profile.log

#var players = game.group(CompA)
# var ite =  queryy[CompA]
# var ite2 = queryy[CompB]

# for ca in ite():
#   echo ca.arg
# for cb in ite2():
#   echo cb.arg
# proc makePlayer*(layer: LayerID): ent {.discardable.} =
#   result = layer.entity()
#var eee = game.entity()
# var ee : ent
# game.entity.make:
#   let ca = e.get CompA
#   ee = e
# game.entity.make:
#   let ca = e.get CompA
#   ee = e

# eee = game.entity().make:
#   let ca = e.get CompA
#echo eee
#echo eee
# game.makeEntity2:
#   let ca = e.get CompA
#   let cb = e.get CompB
#   ca.arg = 1
#   #ca.arg = 1

# game.makeEntity:
#   let ca = e.get CompA
#   let cb = e.get CompB
#   ca.arg = 2
#   #ca.arg = 2

# discard game.makeEntity:
#   let ca = e.get CompA
#   let cb = e.get CompB
#   ca.arg = 3
#   #ca.arg = 3

# discard game.makeEntity:
#   let ca = e.get CompA
#   let cb = e.get CompB
#   ca.arg = 4
#   #ca.arg = 4

# for e, ca, cb in query(Ent, CompA, CompB):
#   if ca.arg == 2:
#     e.kill2()
#   else: echo ca.arg, "__", e
# echo "------------------------"
# for e, ca, cb in query(Ent, CompA, CompB):
#   echo ca.arg, "__", e
  # ca.arg += 1
  # if e.has CompB:
  #   echo "booo"

# var amount = 1000000
# var steps = 60*3600

# discard game.makeEntity(): discard

# profile.start "cc":
#   for i in 0..<amount:
#      discard game.makeEntity():
#        var ca = e.get CompA

# profile.start "gg":
#   for i in 0..<amount:
#      discard game.makeEntity():
#        var ca = e.get CompA

#profile.log
    #  e.get CompA
    #  e.build()

# var saved : ent

# for e, ca in query(Ent, CompA):
#   ca.arg += 1
#   if e.has CompB:
#     saved = e
#     echo "booo"


#game.ecs.kill

# profile.start "xx":
#   for i in 0..<amount:
#      var e = game.entity3()
#echo (10000,1).exist

#profile.log
#echo GC_getStatistics()