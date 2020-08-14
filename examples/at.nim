import actors

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int
type CompD = object
  arg: int


app.add CompA
app.add CompB
app.add CompC
app.add CompD

var game = app.addLayer()
var players = game.group(CompA,CompB)

#echo players.signature
#echo players.signature_excl