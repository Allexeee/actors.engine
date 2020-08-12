import actors

app.settings.fps = 60
app.settings.ups = 60
app.settings.name = "Game"

app.settings.display_size = (1280, 720)
app.settings.path_assets  = "examples/assets/"
app.settings.path_shaders = "examples/assets/shaders/"

var l = addLayer()
#l.addEcs()

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int

app.add CompA
app.add CompB
app.add CompC


var entities = makeEnts()
var size = 20
var ticks = 1#60*3600
let h1 = (size.float*0.5).int
let h2 = (size.float*0.75).int
for i in 0..size:
  var e = l.entity()

  if i<h1:
    e.get CompA
    e.get CompC
  if i<h2:
    e.get CompB
  entities.add(e)

var gr = l.group(mask(CompA,CompB,CompC))

var e1 = (10,0)
var e2 = (51,0)
var check = false

profile.start"by group":
  for x in 0..ticks:
    for e in gr:
      let ca = e.cA
      let cb = e.cB
      let cc = e.cc
      ca.arg+=1
      cb.arg+=1
      cc.arg+=1

profile.start "by indice":
  for x in 0..ticks:
    for c in group(CA,CB,CC):
      c.a.arg += 1
      c.b.arg += 1
      c.c.arg += 1

profile.log

import macros

dumptree:
  iterator group*(t: typedesc, y: typedesc, u: typedesc): tuple[e: ent, a: ptr t, b: ptr y, c: ptr u] =
    let comps1 = t.GetComps()
    let comps2 = y.GetComps()
    let comps3 = u.GetComps()

    let st1 = t.GetStorage()
    let len1 = comps1[].len
    let len2 = comps2[].len
    let len3 = comps3[].len
    let max = if len1 > len2: len2 else: len1
    var i = 0
    while i < max:
      let e = st1.indices[i]
      yield ((e,entitiesMeta[e].age), comps1[][i].addr,comps2[][e].addr, comps3[][e].addr)
      inc i
#[ C
[15:49:17] Benchmark:
Time elapsed for by indice: 0.000000000
Time elapsed for by mask: 2.868000000
]#

#[ CPP

[15:50:30] Benchmark:
Time elapsed for by indice: 0.000000000
Time elapsed for by mask: 2.824000000

]#

# var e = (32,0)

# echo e.has(CompA)

# echo e.HasPoo(CompA)

# l.ecs.execute()



# echo e.sizeof
# profile.start "by ent":
#   for x in 0..ticks:
#     for e in gr:
#       let ca = e.ca()
#       ca.arg += 1


# profile.log

proc init*() =
  makeUIDebug().add()
  discard

proc update*() =
  if input.down Key.Esc:
    app.quit()

proc draw*() =
  for ui in uis:
    ui.draw()
  discard

app.run(init,update,draw)

# newUIDebugGame()

# var triangle : Triangle
# var shader1 : ShaderIndex
# var shader2 : ShaderIndex
# var view_size = 4f
# var mx_ortho = matrix()

# var anim = newSeq[TImage](6)

# var sprite1 : Sprite
# proc gameInit() =
  
#   var aspect_ratio = app.calculate_aspect_ratio()
#   var samplers = [0'u32,1'u32]
#   mx_ortho.ortho(-view_size * aspect_ratio, view_size * aspect_ratio, -view_size, view_size ,-100, 1000)
#   shader1 = app.shader("basic")
#   shader1.use()
#   shader1.setMatrix("mx_projection", mx_ortho)
#   shader2 = app.shader("sprite")
#   shader2.use()

  
#   shader2.setMatrix("mx_projection", mx_ortho)
#   app.vsync(1)


#   sprite1 = addSprite("tex_hero3_idle_01.png", shader1)
#   prepareBatch(shader1)



# var rotate = 0.0
# var scale = 1.0
# var size = vec(1,1)
# var pos = vec(0,0)


# proc gameUpdate() =
#   #if layer 
#   if app.input.down Key.A:
#         pos.x -= 0.02
#   if app.input.down Key.D:
#         pos.x += 0.02
#   if app.input.down Key.W: 
#         pos.y += 0.02
#   if app.input.down Key.S:
#         pos.y -= 0.02
#   if app.input.down Key.Q:
#     rotate -=  2
#   if app.input.down Key.E:
#     rotate += 2
#   if app.input.down Key.Z:
#     scale -= 0.02
#   if app.input.down Key.X:
#     scale += 0.02
#   if input.down Key.Escape:
#     app.quit()

# var col1 = vec(1.0f, 0.5f, 0.2f,1f)
# var col2 = vec(1f, 1f, 1f)

# var anim_frame = 0f





# usePtr[Vertex]()
# import actors/vendor/actors_imgui

# var elements : array[2,float32]

# const amountof = 10

# var poses : array[amountof, Vec2]

# for i in 0..poses.high:
#   var posx = rand(-7.5f..7f)
#   var posy = rand(-4f..3.5f)

#   poses[i] = vec2(posx,posy)


# proc gameDraw() =
#   # частота смены кадра анимации, 1 кадр = 10 шагов

#   anim_frame += 1 / 10
#   glBIndTextureUnit(0, sprite1.texID)
#   glBIndTextureUnit(1, sprite1.texID)
  
#   # cобираем данные
#   for i in 0..amountof-1:
#     sprite1.drawBatched(poses[i],(1f,1f))

#   # вот этот метод рисует
#   flush()
  
#   var nextPos = poses[5].toarray()
#   igBegin("Test")
#   igDragFloat2("Position", nextPos, 0.1)
#   igText("Elements: %i",amountof)
#   igEnd()
#   poses[5] = nextPos.tovec()
  
#   # интерфейсы
#   for ui in uis:
#     ui.draw()

# app.run(gameInit,gameUpdate,gameDraw)


