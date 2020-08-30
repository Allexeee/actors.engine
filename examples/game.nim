import actors

logAdd stdout

app.meta.name = "Pixeye Game"
app.meta.screen_size = (1920,1080)
app.meta.assets_path = "assets/"

var shader_basic : ShaderIndex
var uiDebugGame : UIDebugGame

var uis* = newSeq[UI]()

proc init =
  shader_basic = app.shader("basic")
  uiDebugGame  = newUIDebug(uis)

proc update =
  if input.down Key.Esc:
    app.quit()

proc draw =
  for ui in uis:
    ui.draw()

app.run(init,update,draw)
