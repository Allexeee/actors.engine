import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.fps = 60
app.meta.ups = 50
app.meta.assets_path = "assets/"


var sprite1 : Sprite
var sprite2 : Sprite
var shader1 : ShaderIndex
var ui_debug : UIDebugGame
var uis* = newSeq[UI]()


var cam : Camera # ent
proc init() =
  ui_debug  = newUIDebug(uis)
  cam = newCamera(); cam.ortho(16,9,0.1,1000)
  shader1 = app.shader("basic")
  sprite1 = addSprite("tex_larva_idle_01.png", shader1)
  sprite2 = addSprite("tex_hero3_idle_01.png", shader1)


var p = vec(0,0)
var p2 = vec(0.4,0)

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
    p.x -= 0.02
  if input.down Key.D:
    p.x += 0.02


var size = vec(1,1)

proc draw() =
  sprite1.draw(p,size,0)
  sprite2.draw(p2,size,0)
  sprite2.draw(p2-p2*12,size,0)

  for ui in uis:
    ui.draw()

app.run(init,update,draw)
