{.used.}
{.experimental: "codeReordering".}

import actors
import ui
import renderer
import actors/vendor/actors_gl
import random

app.settings.fps = 60
app.settings.ups = 60
app.settings.name = "Game"

app.settings.display_size = (1920, 1080) 
app.settings.path_assets  = "examples/assets/"
app.settings.path_shaders = "examples/assets/shaders/"

newUIDebugGame()

var triangle : Triangle
var quad     : Quad
var shader1 : ShaderIndex
var shader2 : ShaderIndex
var view_size = 4f
var mx_ortho = matrix()

var image  : TImage = loadImage("awesomeface.png")
var image2 : TImage = loadImage("tex_hero2_idle_04.png")

var anim = newSeq[TImage](6)

#tex_hero3_idle_01

proc gameInit() =

  for i in 1..anim.high:
    anim[i-1] = loadImage(&"tex_hero3_idle_0{i}.png")
    anim[i-1].generate(GL_RGBA)
  var aspect_ratio = app.calculate_aspect_ratio()
  mx_ortho.ortho(-view_size * aspect_ratio, view_size * aspect_ratio, -view_size, view_size ,0.01, 1000)
  shader1 = app.shader("basic")
  shader1.use()
  shader1.setMatrix("mx_projection", mx_ortho)
  shader2 = app.shader("sprite")
  shader2.use()
 
  shader2.setMatrix("mx_projection", mx_ortho)
 # shader2.setInt("image",0)
  app.vsync(1)
  triangle = initTriangle(shader1)
  quad     = initQuad(shader1)
  image.generate(GL_RGBA)
  image2.generate(GL_RGBA)


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

var col1 = vec(1.0f, 1f, 1f)
var col2 = vec(1f, 1f, 1f)

var anim_frame = 0f


#randomize()

proc gameDraw() =
  # частота смены кадра анимации, 1 кадр = 10 шагов
  anim_frame += 1 / 10
  # рисуем квад с картинкой. В нашей анимации 5 кадров
 # quad.shader.use()
  
  var img = anim[(int)anim_frame mod 5]
  quad.draw(pos, size*scale, rotate,col1)
  # for i in 0..10000:
  #   var rx = (float)(rand(-0.15..0.15) * (float)i)
  #   var ry = (float)(rand(-0.15..0.15) * (float)i)
  #   quad.draw(img, pos+vec(rx,ry), size*scale, rotate,col1)
 
  # интерфейсы
  for ui in uis:
    ui.draw()

app.run(gameInit,gameUpdate,gameDraw)


