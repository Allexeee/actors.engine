import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.fps = 60
app.meta.ups = 50
app.meta.assets_path = "assets/"

var shader_basic : ShaderIndex
var uiDebugGame : UIDebugGame

var uis* = newSeq[UI]()

proc init() =
  uiDebugGame  = newUIDebug(uis)
  shader_basic = app.shader("basic")
  var aspect_ratio = app.calculate_aspect_ratio()


#   var aspect_ratio = app.calculate_aspect_ratio()
#   var samplers = [0'u32,1'u32]
#   mx_ortho.ortho(-view_size * aspect_ratio, view_size * aspect_ratio, -view_size, view_size ,-100, 1000)
#   shader1 = app.shader("basic")
#   shader1.use()
#   shader1.setMatrix("mx_projection", mx_ortho)
#   shader2 = app.shader("sprite")
#   shader2.use()


proc update() =
  if input.down Key.Esc:
    app.quit()

proc draw() =
  for ui in uis:
    ui.draw()

app.run(init,update,draw)
