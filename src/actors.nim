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
  #igSetMouseCursor(ImGuiMouseCursor.None)

proc renderEnd() =
 # igSetMouseCursor(ImGuiMouseCursor.None)
  plugins.imgui_impl.renderEnd()
  engine.target.renderEnd()
  
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
  engine.target.bootstrap(app)
  plugins.imgui_impl.bootstrap(window)

  #igSetMouseCursor(ImGuiMouseCursor.None)
  #if io.MouseDrawCursor: discard
   #SetCursor(nil)
  #igSetMouseCursor(ImGuiMouseCursor.None)
  # if app.meta.showCursor == false:
  #   window.setInputMode(GLFWCursorSpecial,GLFWCursorHidden)
  # else:
  #   window.setInputMode(GLFWCursorSpecial,GLFWCursorNormal)
  
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
      var mm =  cam.cTransform.model; 
      mm.scale(1,1,1)
      mm.rotate(0, vec_forward)
      mm.translate(vec(cam.cTransform.pos.x,cam.cTransform.pos.y,0,1)) 
      mm.invert()
      var m = cam.cCamera.projection * mm
      shaders[0].use()
      shaders[0].setMatrix("mx_projection",m)
      renderBegin()
      draw()
      renderEnd()
    
    metricsEnd()
  
  #release
  engine.release()
  plugins.release()


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



