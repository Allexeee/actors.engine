import actors

logAdd stdout

app.meta.name = "Pixeye"
app.meta.screen_size = (1920,1080)
app.meta.assets_path = "assets/"

var shader_basic : ShaderIndex

proc init =
  shader_basic = app.shader("basic")
  discard

proc update =
  if input.down Key.Esc:
    app.quit()

proc draw =
  discard


app.run(init,update,draw)
