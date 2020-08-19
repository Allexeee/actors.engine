import actors


# var st1 = {0,1}
# var st2 : set[uint16]
# st2 = {}
# var st3 = "CompB"
# echo st1.hash
# echo st2.hash
# echo st3.hash

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

var players = game.group(CompA)

var en = game.entity:
  let ca = e.get CompA
  let cb = e.get CompB

en.kill()
#en.kill()

# for x in 0..<5000:
#   discard game.entity:
#     let ca = e.get CompA


# var i = 0;
# for x in 0..<(60*3600):
#   profile.start "cached":
#     for e in players:
#       let ca = e.compA
#       ca.arg += 1

#   profile.start "'dynamic'":
#     for e in game.group(CompA,!CompC):
#       i+=1 
#       let ca = e.compA
#       ca.arg += 1
      
#   profile.start "query":
#     for ca in query(CompA):
#       ca.arg += 1

# log i
# profile.log