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
var shader2 : ShaderIndex
var uiw_debug : UiDebugGame
var ui* = newSeq[UiWindow]()
var sizeca = 4f

var amount = 111
var positions = newSeq[Vec](amount)
var colors = newSeq[Vec](amount)

var cam : Camera # ent

for i in 0..<amount:
  positions[i].rnd(8,4)
  let r = rand(0..3)
  case r:
  of 0:
    colors[i] = vec(1,0,0,1)
  of 1:
    colors[i] = vec(0,1,0,1)
  of 2:
    colors[i]     = vec(0,0.5,1,1)
  else: colors[i] = vec(1,1,1,1)


proc init() =
  cam       = getCamera();

  uiw_debug  = ui.getWindowDebug()

  shader1   = db.getShader("basic")
  shader2   = db.getShader("test")

  #dbGet

  sprite    = db.getSprite("tex_aidKit2.png", shader1)

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
  cam.ortho(w,h,-1000,1000)
  for i in 0..<amount:
    makeQuad(positions[i].x,positions[i].y,colors[i],0)


#op
var pos  = vec(0,0)

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
    pos.x += 0.2
  if input.press Key.Q:
    sizeca -= 1
  if input.press Key.E:
    sizeca += 1


var r  = 0f
var ccos : float
var csin : float
var p = 0f
var a = 1f

proc test(a,b:float) =
  p = 1 * a - 2 * b

proc draw() =
  var s : Vec = (1f,1f)
  

  updatePos(0,0,1)
  updatePos(0,0.1,-1)

  # for i in 0..<amount:
  #   updatePos(0,0)
  
  var pos = cam.ctransform.pos
  cam.ctransform.model.setPosition(0,0,0)
  shaders[1].use()
  var m = cam.ccamera.projection * cam.ctransform.model
  shaders[1].setMat("m_projection",m)
 
  drawLine(0,1,shaders[1])
  cam.ctransform.model.setPosition(pos)
 # drawLine(cam.x,cam.y,shader2)
  # drawLine(0,1,shader2)
  # drawLine(2,1,shader2)
  # drawLine(0,0,shader2)
  # if input.press Key.Space:
  #   profile "COS":
  #     for i in 0..<250_000:
  #       var rr = rand(-1f..1f)
  #       ccos = cos(r)*rr
  #       csin = sin(r)*rr
  #     r += 2
  #   profilelog()
    #test(ccos,csin)
   #let x = rand(-8f..8f)
   #let y = rand(-4f..4f)
    #updateNose()
    #updatePos(x,y)
  #updateTiles()
    #updateAll(0,0,36,r)
    #updateNose()
  #   updateNose()
    #updateAll(x,y,64,r)
  
  # p = r * csin - r * ccos
  # if p == a:
  #   echo "T"
  for elem in ui:
    elem.draw()


app.run(init,update,draw)
