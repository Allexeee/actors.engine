import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screenSize = (1920,1080)
app.meta.fullScreen = false
app.meta.showCursor = false
app.meta.fps = 60
app.meta.ups = 50
app.meta.ppu = 32
app.meta.assetsPath = "assets/"

 
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
  #echo sprite1.x, "__", sprite1.y
#op
var pos  = vec(0,-19)
var pos2 = vec(0,20)
var pos3 = vec(546,20)
var pos4 = vec(-546,20)
var pos5 = vec(-546*2,20)
var pos6 = vec(546*2,20)
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
  

var wallSize = vec(1,1)
var medSize = vec(3,3)
var rotate = 1f

proc draw() =
  
  sprite.draw(pos,med_size,rotate)

  rotate += 1

  for ui in uis:
    ui.draw()


app.run(init,update,draw)
