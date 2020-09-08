import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screenSize = (1920,1080)
app.meta.fullScreen = false
app.meta.showCursor = false
app.meta.fps = 1000
app.meta.ups = 50
app.meta.ppu = 32 
app.meta.assetsPath = "assets/"

# var arr {.noinit.} : array[600_000,uint32]

# proc test*()=
#   var indices {.noinit,global.} : array[600_000,uint32]
#   echo sizeof(indices), "bo"



#var indices : array[600_000,uint32] #newSeq[uint32](maxIndexCount)
#echo sizeof(indices), "bo"
var sprite : Sprite
var sprite2 : Sprite
var shader1 : ShaderIndex
var ui_debug : UiDebugGame
var uis* = newSeq[UiWindow]()
var sizeca = 4f

var cam : Camera # ent
proc init() =
  cam       = getCamera();
  ui_debug  = uis.getDebugWindow()
  shader1   = db.getShader("basic")
  sprite    = db.getSprite("tex_aidKit2.png", shader1)
  sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)
  var h = sizeca
  var w = h * 1920/1080
  cam.ortho(w,h,0.1,1000)
#op
var pos  = vec(0,-19)
# var pos2 = vec(0,20)
# var pos3 = vec(546,20)
# var pos4 = vec(-546,20)
# var pos5 = vec(-546*2,20)
# var pos6 = vec(546*2,20)
proc update() =
  if input.down Key.Esc:
    app.quit()
  if input.down Key.Left:
    cam.x -= 0.01
  if input.down Key.Right:
    cam.x += 0.01
  if input.down Key.Up:
    cam.y += 0.01
  if input.down Key.Down:
    cam.y -= 0.01
  if input.down Key.A:
    pos.x -= 1
  if input.down Key.D:
    pos.x += 1
  if input.press Key.Q:
    sizeca -= 1
  if input.press Key.E:
    sizeca += 1
  if input.press Key.I:
    app.setFullScreen(true)

  if input.press Key.O:
    app.setFullScreen(false)
  

 
#var rotate = 1f
#var size = (1f,1f)
var amount = 50000
var positions = newSeq[Vec](amount)

#import random

for i in 0..<amount:
  positions[i].rnd(200,100)


var mode = 0

proc draw() =

  if input.press Key.K1:
    mode = 0
  if input.press Key.K2:
    mode = 1
  #var p : Vec = (0f,0f)
  var s : Vec = (1f,1f)
  var r  = 0f
  for i in 0..<amount:
    drawQuad(positions[i],s,r)
  #sprite.shader.use()

  # case mode:
  # of 0:
  #   for i in 0..<amount:
  #     draw(sprite,positions[i],size,0)
  # of 1:
  #   for i in 0..<amount:
  #     drawB(sprite,positions[i],size,0)
  # else: discard

  for ui in uis:
    ui.draw()


app.run(init,update,draw)
