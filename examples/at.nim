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


var lgame = addLayer()


var g = lgame.group(by(CompA),excl(CompB))

echo CompA.id, CompB.id
# var c = by(CompA)
# c[0] = 1000.cid

# echo c[0]
# echo maskCache[0]


#var players = lgame.