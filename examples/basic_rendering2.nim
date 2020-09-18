import random
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

var sprite  : Sprite
var sprite2 : Sprite
var shader1 : ShaderIndex
var uiw_debug : UiDebugGame
var ui* = newSeq[UiWindow]()
var sizeca = 4f

var amount = 1_000_000
var positions = newSeq[Vec](amount)
var colors = newSeq[Vec](amount)

var cam : Camera # ent

for i in 0..<amount:
  positions[i].rnd(6,4)
  let r = rand(0..3)
  case r:
  of 0:
    colors[i] = vec(1,0,0,1)
  of 1:
    colors[i] = vec(0,1,0,1)
  of 2:
    colors[i]     = vec(0,0,1,1)
  else: colors[i] = vec(1,1,1,1)


proc init() =
  cam       = getCamera();

  uiw_debug  = ui.getWindowDebug()

  shader1   = db.getShader("basic")

  #dbGet

  sprite    = db.getSprite("tex_aidKit2.png", shader1)

  sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)
  sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)
  sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)
  

  #db_get_sprite
  #db_get_shader
  #db_get_font
  #rt_get_camera
  #rt_get_ent
  #ecs_get_ent
  #getEnt()

  #sprite2   = sprite_get()
  #sprite2   = db.getSprite("tex_st1_wall1_03.png", shader1)
  
  var h = sizeca
  var w = h * 1920/1080
  cam.ortho(w,h,0.1,1000)
  for i in 0..<amount:
    makeQuad(positions[i].x,positions[i].y,colors[i],0)


#op
var pos  = vec(0,-19)

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



proc draw() =
  var s : Vec = (1f,1f)
  var r  = 0f
  #test()
  for i in 0..<amount:
   updatePos(positions[i].x,positions[i].y)
  
  for elem in ui:
    elem.draw()


app.run(init,update,draw)
