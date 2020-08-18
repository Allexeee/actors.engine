import actors


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

var players = game.group(CompA)

proc makePlayer*(layer: LayerID): ent {.discardable.} =
  result = layer.entity()





var amount = 1000000
var steps = 60*3600

profile.start "cc":
  for i in 0..<amount:
     discard game.makeEntity():
       var ca = e.get CompA

# profile.start "gg":
#   for i in 0..<amount:
#      discard game.makeEntity():
#        var ca = e.get CompA

profile.log
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