import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.fps = 60
app.meta.ups = 50
app.meta.assets_path = "assets/"


var sprite1 : Sprite
var shader1 : ShaderIndex
var ui_debug : UIDebugGame
var mx_ortho : Matrix
var uis* = newSeq[UI]()


proc init() =
  ui_debug  = newUIDebug(uis)
  shader1 = app.shader("basic")
  var aspect_ratio = app.meta.screen_size.width/app.meta.screen_size.height
  mx_ortho.ortho(-4f * aspect_ratio, 4f * aspect_ratio, -4f, 4f ,-100, 1000)
  shader1.use()
  shader1.setMatrix("mx_projection", mx_ortho)
  sprite1 = addSprite("tex_larva_idle_01.png", shader1)
  prepareBatch(shader1)


proc update() =
  if input.down Key.Esc:
    app.quit()

proc draw() =
  
  glBIndTextureUnit(1, sprite1.texID)
  sprite1.drawBatched((0f,0f),(1f,1f))

  flush()
  for ui in uis:
    ui.draw()

app.run(init,update,draw)
