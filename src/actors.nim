## Created by Pixeye | dev@pixeye.com
##   
## ❒ The game engine
## * ``actors_math``    gamedev specific math api and types
## * ``actors_ecs``     entity-component-system (ECS)
## * ``actors_tools``   auxiliary stuff and sugar extensions
## * ``actors_plugins`` third party libraries



{.used.}
{.experimental: "codeReordering".}

import actors/actors_h       
import actors/actors_plugins as plugins
import actors/actors_tools   as tools
import actors/actors_engine  as engine

export tools
export engine
export plugins
export actors_h.LayerId
export actors_h.AppTime
export actors_h.db
export actors_h.app


proc quit*(self: App) =
  engine.target.quit()

proc appSleep(t: float32) =
  var timeCurrent = engine.getTime()
  while timeCurrent - app.time.last < t:
    sleep(0)
    timeCurrent = engine.getTime()

proc metricsBegin()=
  let timer = app.time #ref
  timer.counter.frames += 1
  timer.frames += 1

proc metricsEnd()=
  let timer = app.time #ref
  let counter = app.time.counter.addr #pointer
  if engine.getTime() - timer.seconds > 1.0:
    timer.seconds += 1
    counter.updates_last = counter.updates
    counter.frames_last = counter.frames
    counter.updates = 0
    counter.frames  = 0

proc renderBegin()=
  plugins.imgui_impl.renderBegin()
  engine.target.renderBegin()

proc renderEnd() =
  plugins.imgui_impl.renderEnd()
  engine.target.renderEnd()
  stats.sprites_prev = stats.sprites
  stats.drawcalls_prev = stats.drawcalls
  stats.sprites = 0
  stats.drawcalls = 0
  if app.meta.vsync == 0:
    appSleep(1f/app.meta.fps)


template fixedUpdate(code: untyped): untyped =
    let ms_per_update = MS_PER_UPDATE()
    let timer = app.time #ref
    let timeCurrent = engine.getTime()
    let tdelta = timeCurrent - timer.last
    
    timer.dt = tdelta
    timer.last = timeCurrent
    timer.lag += tdelta
    
    engine.target.pollEvents()
    
    while timer.lag >= ms_per_update:
      code
      timer.lag -= ms_per_update
      timer.counter.updates += 1


proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  engineInit()
  pluginsInit(window)

  init()
  
  while not engine.target.shouldQuit():
    metricsBegin()
    #logic
    fixedUpdate:
      update()

    #draw & ui
    var cam : Camera
    for e, cCamera in ecsQuery(Ent,CompCamera):
      if cCamera.main == true:
        cam = e
    
    if cam != ent.default:
      var сm =  cam.cTransform.model
      сm.scale(1,1,1)
      сm.rotate(0, vec_forward)
      сm.translate(vec(cam.cTransform.pos.x,cam.cTransform.pos.y,0,1)) 
      сm.invert()
      var m = cam.cCamera.projection * сm
      shaders[0].use()
      shaders[0].setMatrix("mx_projection",m)
      renderBegin()
      batchBegin()
      draw()
      batchEnd()
      flush()
      renderEnd()
    
    metricsEnd()
  
  #release
  plugins.release()
  engine.release()

