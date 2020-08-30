## Created by Pixeye | dev@pixeye.com
##
## The game engine.

{.used.}
{.experimental: "codeReordering".}

import actors/actors_plugins as plugins
import actors/actors_h       as core
import actors/actors_tools   as tools
import actors/actors_engine  as engine

export tools
export engine
export plugins
export core.LayerId

let app* = core.app

template updateClamp*(code: untyped): untyped =
  let ms_per_update = MS_PER_UPDATE()
  let timer = app.time #ref
  let timeCurrent = engine.getTime()
  let tdelta = timeCurrent - timer.last
  timer.last = timeCurrent
  timer.lag += tdelta
  while timer.lag >= ms_per_update:
    code
    timer.lag -= ms_per_update
    timer.counter.updates += 1

proc metrics_begin()=
  let timer = app.time #ref
  timer.counter.frames += 1
  timer.frames += 1

proc metrics_end()=
  let timer = app.time #ref
  let counter = app.time.counter.addr #pointer
  if engine.getTime() - timer.seconds > 1.0:
    timer.seconds += 1
    counter.updates_last = counter.updates
    counter.frames_last = counter.frames
    counter.updates = 0
    counter.frames  = 0

proc sleep*(app: App, t: float) =
  var timeCurrent = engine.getTime()
  while timeCurrent - app.time.last < t:
    sleep(0)
    timeCurrent = engine.getTime()

proc renderer_end() =
  engine.target.render_end()
  if app.meta.vsync == 0:
    app.sleep(1/app.meta.fps)


proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  var w = engine.target.bootstrap(app)
  let context {.used.} = igCreateContext()
  assert igGlfwInitForOpenGL(w, true)
  assert igOpenGL3Init()
  igStyleColorsCherry()

  init()
  
  while not engine.target.shouldQuit():
    
    metrics_begin()
    engine.target.pollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    updateClamp:
      update()

    engine.target.render_begin()
    #plugins.render_begin()
    
    draw()
    igRender()

    #plugins.flush()
    igOpenGL3RenderDrawData(igGetDrawData())
    renderer_end()
    #engine.target.render_end()
    
    metrics_end()
    echo app.time.counter.frames
  #plugins.kill()
  engine.target.kill()
    
#plugins.imgui.kill()
#in_engine.target.kill()

#var frame* : int

# proc run*(app: App,init: proc(), update: proc(), draw: proc()) =
#   engine.target.start(app.settings.display_size, app.settings.name)
#   app.time.lag  = 0
#   app.time.last = app.time.current
#   app.vsync(app.settings.vsync)
 
#   #var ms_update = 0f
#   #var ms_render = 0f

#   init()

#   while not engine.target.shouldQuit():
#     app.time.frames += 1
#     app.time.counter.frames += 1
#     frame += 1
#     engine.target.pollEvents()
    
#     #clampUpdate():
#     #  update()
    
#     #igOpenGL3NewFrame()
#     plugins.imgui.renderer_begin()
    
#     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
#     if app.settings.vsync == 1:
#       glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
#     else:
#       glClearColor(0.2f, 0.4f, 0.3f, 1.0f)


#     draw()
    
#     plugins.imgui.flush()
#     renderer_end()
    
#     # echo "msu: ", ms_update
#     # echo "msr: ", ms_render
  
#   plugins.imgui.dispose()
#   engine.target.dispose()



# proc quit*(this: App) =
#   engine.target.release()

# proc sleep*(app: App, t: float) =
#   var time_current = app.getTime()
#   while time_current - app.time.last < t:
#     sleep(0)
#     time_current = app.getTime()

# template renderer_end(): untyped =
#   engine.target.render_end(app.settings.vsync)
#   if app.settings.vsync == 0:
#     app.sleep(1/app.settings.fps)
