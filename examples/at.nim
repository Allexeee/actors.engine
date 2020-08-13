import actors

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int

app.add CompA
app.add CompB
app.add CompC

var lgame = app.addLayer()
var g = lgame.group(CompA,CompB)


proc makePlayer(layer: LayerId): ent =
  result = layer.entity()
  var ca = result.get CompA
  var cb = result.get CompB
  ca.arg = 5
  cb.arg = 10






var e = lgame.makePlayer()



var elements = newSeq[int](32)

for i in 0..elements.high:
  elements[i]= i


# proc evAdd() =
#   echo " pii"
#   elements.add(10)
#   discard

# for i in countdown(elements.high,0):
#   if i==16:
#     evAdd()
#     elements.delete(i)
#     continue
#   echo elements[i]

# for i in countdown(elements.high,0):
#   echo elements[i]
#echo elements


# var x = 0
# profile.start "Down":
#   for a in 0..60*10000:
#     for i in countdown(32,0):
#       x += 1
# profile.start "Up":
#   for a in 0..60*10000:
#     for i in 0..32:
#       x += 1

# profile.log


#  if i == 12:
#    elements.delete(i)
#  if i == 11:
#    elements.add(12)
   
#  echo elements[i]

# echo CompA.id, CompB.id
# var c = by(CompA)
# c[0] = 1000.cid

# echo c[0]
# echo maskCache[0]


#var players = lgame.