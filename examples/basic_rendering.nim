import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.fps = 60
app.meta.ups = 50
app.meta.ppu = 32
app.meta.assets_path = "assets/"


var sprite1 : Sprite
var sprite2 : Sprite
var shader1 : ShaderIndex
var ui_debug : UIDebugGame
var uis* = newSeq[UI]()


var cam : Camera # ent
proc init() =
  ui_debug  = getUIDebug(uis)
  cam = getCamera(); cam.ortho(16/4,9/4,0.1,1000)
  shader1 = getShader("basic")
  sprite1 = getSprite("tex_larva_idle_01.png", shader1)
  sprite2 = getSprite("tex_st2_wall1_01.png", shader1)
  

var p = vec(0,-19)
var p2 = vec(1,20)
var p3 = vec(115,20)
var p4 = vec(-115,20)
var p5 = vec(-115*2,20)
var p6 = vec(115*2,20)
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
  if input.down Key.Q:
    echo "a"
  if input.down Key.E:
    echo "a"

var size = vec(1,1)

proc draw() =
  sprite1.draw(p,size,0)
  sprite2.draw(p2,size*4,0)
  sprite2.draw(p3,size*4,0)
  sprite2.draw(p4,size*4,0)
  sprite2.draw(p5,size*4,0)
  sprite2.draw(p6,size*4,0)
  echo p

  for ui in uis:
    ui.draw()

app.run(init,update,draw)
