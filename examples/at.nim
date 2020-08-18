import actors

type CompA = object
  arg: int
type CompB = object
  arg: int

var game = app.addLayer(); game.use()

app.add CompA
app.add CompB

proc makeA*(layer: LayerID) : ent =
  result = layer.entity()
  result.get CompA

var e = game.makeA()

game.ecs.execute()

echo e.has CompA

e.kill()

game.ecs.execute()

echo e.has CompA