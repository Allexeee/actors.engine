import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.fps = 1000
app.meta.ups = 50
app.meta.ppu = 32
app.meta.assets_path = "assets/"


var sprite1 : Sprite
var sprite2 : Sprite
var shader1 : ShaderIndex
var ui_debug : UiDebugGame
var uis* = newSeq[UiWindow]()
var sizeca = 4f
import random

var poses {.noinit.} : array[2_000_000,Vec2]
var cam : Camera # ent
proc init() =
  ui_debug  = uis.getWindowDebug()
  cam = getCamera();
  shader1 = db.getShader("basic")
  sprite1 = db.getSprite("tex_aidKit2.png", shader1)

  for i in 0..<1_500_000:
    poses[i] = vec2(rand(-256f..256f),rand(-128f..128f))
    draw_quad(poses[i].x,poses[i].y,0,sprite1.w*0.004f*4,sprite1.h*0.004f*4,1)
    #sprite1.draw(vec(poses[i].x,poses[i].y),vec(0.1,0.1),0)
  


var amount = 1
var p  = vec(0,-19)
# var p2 = vec(0,20)
# var p3 = vec(546,20)
# var p4 = vec(-546,20)
#var p5 = vec(-546 *2,20)
#var p6 = vec(546 * 2,20)
var t = 0
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
  if input.down Key.Space:
    for i in 0..<1_500_000:
      poses[i] = vec2(rand(-256f..256f),rand(-128f..128f))
      sprite1.draw(vec(poses[i].x,poses[i].y),vec(0.1,0.1),0)
    # var a = amount
    # amount += 2000
    # for i in a..amount:
    #   poses[i] = vec2(rand(-256f..256f),rand(-128f..128f))
  if input.down Key.Z:
    t = 1
  if input.down Key.X:
    t = 0
    
var r = 0f




proc draw() =

  # for i in 0..<500_000:
  #     poses[i] = vec2(rand(-256f..256f),rand(-128f..128f))
  #     sprite1.draw(vec(poses[i].x,poses[i].y),vec(0.1,0.1),0)
  # if t == 1:
  #   for i in 0..<amount:
  #     draw_quad(poses[i].x,poses[i].y,0,sprite1.w*0.004f*4,sprite1.h*0.004f*4,1)
  # else:
  #   for i in 0..<amount:
  #     sprite1.draw(vec(poses[i].x,poses[i].y),vec(0.1,0.1),0)
  render_update(1_500_000)
  ig_begin("Camera")
  ig_pushItemWidth(320)
  ig_sliderFloat(" Size", sizeca.addr, 1, 1000, "%.0f")
  ig_end()

  var h = 1*sizeca
  var w = h * 1920f/1080f
  cam.ortho(w,h,0.1,1000)
  for ui in uis:
    ui.draw()
    

app.run(init,update,draw)
