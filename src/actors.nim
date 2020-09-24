## Created by Pixeye | dev@pixeye.com
##
## ❒ The game engine
## * ``actors_math``    gamedev specific math api and types
## * ``actors_ecs``     entity-component-system (ECS)
## * ``actors_tools``   auxiliary stuff and sugar extensions
## * ``actors_plugins`` third party libraries


{.used.}
{.experimental: "codeReordering".}

import actors/px_h       
import actors/px_plugins as plugins
import actors/px_tools   as tools
import actors/px_engine  as engine

export tools
export engine
export plugins
export px_h.LayerId
export px_h.AppTime
export px_h.db
export px_h.app


proc quit*(self: App) =
  engine.target.quit()

proc appSleep(t: float32) =
  var timeCurrent = engine.getTime()
  while timeCurrent - app.time.last < t:
    sleep(0)
    timeCurrent = engine.getTime()

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

proc render_begin()=
  plugins.px_imgui.render_begin()
  engine.px_platform.render_begin()
  #engine.target.renderBegin()
  #engine.px_platform.render_begin()
  #engine.platform.render_begin()
proc render_end() =
  plugins.px_imgui.render_end()
  engine.px_platform.render_end()
  #engine.target.renderEnd()
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



#proc drawui() =
 # drawLine(0,1,shaders[1])

proc camera_update() =
  var cam : Camera

  for e, ccamera in ecsquery(Ent,CCamera):
    if ccamera.main == true:
      cam = e
  
  if cam != ent.default:
    let pos = cam.ctransform.pos
    var cm  = cam.ctransform.model
    
    cm.scale(1,1,1)
    cm.rotate(0,vec_forward)
    cm.translate(vec(pos.x,pos.y,0,1))
    cm.invert()

    var m = cam.ccamera.projection * cm
    var model = matrix()
    for shader in shaders:
      shader.use()
      shader.setMat("m_projection",m)
      shader.setMat("m_model",model)
        #shaders[0].use()
 # var model = matrix()
 # shaders[0].setMat("m_model",model)


proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  engine_init()
  plugins_init(window)
  init()
  render_init_finish()
  
  while not engine.target.shouldQuit():
    metrics_begin()
    #logic
    fixedUpdate:
      update()

    #draw & ui
    camera_update()
    render_begin()
    draw()
    render_end()
    metrics_end()
  
  #release
  plugins.release()
  engine.release()



## asserts - check engine errors, never user-side (game-engine-architecture, 147)
## 
