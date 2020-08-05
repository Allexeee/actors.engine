{.used.}
{.experimental: "codeReordering".}

import actors
import ui
import renderer
import actors/vendor/actors_gl
import random
import actors/vendor/actors_imgui


app.settings.fps = 60
app.settings.ups = 60
app.settings.name = "Game"

app.settings.display_size = (1920, 1080) 
app.settings.path_assets  = "examples/assets/"
app.settings.path_shaders = "examples/assets/shaders/"

newUIDebugGame()

var triangle : Triangle
#var quad     : Quad
var shader1 : ShaderIndex
var shader2 : ShaderIndex
var view_size = 4f
var mx_ortho = matrix()



var anim = newSeq[TImage](6)

#tex_hero3_idle_01

proc gameInit() =


  #createQuad(0f,0f)
  # for i in 1..anim.high:
  #   anim[i-1] = loadImage(&"tex_hero3_idle_0{i}.png")
  #   anim[i-1].generate(GL_RGBA)
  var aspect_ratio = app.calculate_aspect_ratio()
  mx_ortho.ortho(-view_size * aspect_ratio, view_size * aspect_ratio, -view_size, view_size ,-100, 1000)
  shader1 = app.shader("basic")
  shader1.use()
  shader1.setMatrix("mx_projection", mx_ortho)
  shader2 = app.shader("sprite")
  shader2.use()
 
  shader2.setMatrix("mx_projection", mx_ortho)
 # shader2.setInt("image",0)
  app.vsync(1)
  triangle = initTriangle(shader1)
  #quad     = initQuad(shader1)
  
  
  #echo image.id, "___", image2.id

  #var loc = glGetUniformLocation()



var rotate = 0.0
var scale = 1.0
var size = vec(1,1)
var pos = vec(0,0)


proc gameUpdate() =
    

  #if layer 

  if app.input.down Key.A:
        pos.x -= 0.02
  if app.input.down Key.D:
        pos.x += 0.02
  if app.input.down Key.W: 
        pos.y += 0.02
  if app.input.down Key.S:
        pos.y -= 0.02
  if app.input.down Key.Q:
    rotate -=  2
  if app.input.down Key.E:
    rotate += 2
  if app.input.down Key.Z:
    scale -= 0.02
  if app.input.down Key.X:
    scale += 0.02
  if input.down Key.Escape:
    app.quit()

var col1 = vec(1.0f, 0.5f, 0.2f,1f)
var col2 = vec(1f, 1f, 1f)

var anim_frame = 0f


proc gameDraw() =
  # частота смены кадра анимации, 1 кадр = 10 шагов
  anim_frame += 1 / 10
  
  #initialize(quad.shader)
  #drawTest()
 
  # интерфейсы
  for ui in uis:
    ui.draw()

app.run(gameInit,gameUpdate,gameDraw)


