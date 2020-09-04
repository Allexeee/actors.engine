import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screenSize = (1920,1080)
app.meta.fullScreen = true
app.meta.showCursor = true
app.meta.fps = 60
app.meta.ups = 50
app.meta.ppu = 32
app.meta.assetsPath = "assets/"


  

var sprite1 : Sprite
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
  sprite1   = db.getSprite("tex_aidKit2.png", shader1)
  sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)

var p  = vec(0,-19)
var p2 = vec(0,20)
var p3 = vec(546,20)
var p4 = vec(-546,20)
var p5 = vec(-546*2,20)
var p6 = vec(546*2,20)
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
    p.x -= 1
  if input.down Key.D:
    p.x += 1
  if input.press Key.Q:
    sizeca -= 1
  if input.press Key.E:
    sizeca += 1
  if input.press Key.I:
    app.getFullScreen(true)

  if input.press Key.O:
    app.getFullScreen(false)
  

var size = vec(546f/app.meta.ppu,500f/app.meta.ppu)
var med_size = vec(36f/app.meta.ppu,26f/app.meta.ppu)
proc draw() =
  sprite2.draw(p2,size,0)
  sprite2.draw(p3,size,0)
  sprite2.draw(p4,size,0)
  sprite2.draw(p5,size,0)
  sprite2.draw(p6,size,0)
  sprite1.draw(p,med_size,0)
  #echo p

  igBegin("Camera")
  igPushItemWidth(320)
  igSliderFloat(" Size", sizeca.addr, 1, 1000, "%.0f")
  igEnd()

  var h = 1*sizeca
  var w = h * 1920/1080
  cam.ortho(w,h,0.1,1000)
  for ui in uis:
    ui.draw()


app.run(init,update,draw)
