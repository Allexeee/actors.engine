## closure ienumerators
{.used.}
{.experimental: "codeReordering".}

import times
import os
import strformat
import actors/actors_engine  as engine
import actors/actors_runtime as runtime
import actors/actors_utils   as utils
import actors/vendor/actors_gl
import actors/vendor/actors_glfw

import actors/vendor/actors_imgui
import actors/vendor/actors_gl

export engine except
  app,
  setProcs


export runtime
export utils


var render* : proc()

engine.core.setProcs(engine.target.getTime)

engine.core.pressKey         = engine.target.pressKeyImpl
engine.core.pressMouse       = engine.target.pressMouseImpl 
engine.core.getMousePosition = engine.target.getMousePositionImpl


let app* = App()
app.time = AppTime()
app.settings = AppSettings()

engine.core.app = app

let layerApp* = app.addLayer(); layerApp.setActive()
layerApp.entity()

let input* = app.addInput()


proc getTime* (app: App) : float {.inline.} =
  engine.target.getTime()

proc vsync*(app: App, arg: int32) =
  if arg != app.settings.vsync:
    app.settings.vsync = arg
    engine.target.setVSync(app.settings.vsync)

var context : ptr ImGuiContext

var frame* : int

proc run*(app: App,init: proc(), update: proc(), draw: proc()) =
  engine.target.start(app.settings.display_size, app.settings.name)
  app.time.lag  = 0
  app.time.last = app.getTime()
  engine.target.setVSync(app.settings.vsync)

  context = igCreateContext()
  igStyleColorsCherry()
  assert igGlfwInitForOpenGL(window, true)
  assert igOpenGL3Init()
  #var ms_update = 0f
  #var ms_render = 0f

  init()

  while not engine.target.shouldQuit():
    
    app.time.frames += 1
    app.time.counter.frames += 1
    frame += 1
    engine.target.pollEvents()
    
    clampUpdate():
      update()
    
    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    if app.settings.vsync == 1:
      glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
    else:
      glClearColor(0.2f, 0.4f, 0.3f, 1.0f)


    draw()
  
    igRender()
    igOpenGL3RenderDrawData(igGetDrawData())
    
    
    #ms_render = app.getTime() - ms_render
    renderer_end()
    
    # echo "msu: ", ms_update
    # echo "msr: ", ms_render
  
  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()
  engine.target.dispose()



proc quit*(this: App) =
  engine.target.release()


proc sleep*(app: App, t: float) =
  var time_current = app.getTime()
  while time_current - app.time.last < t:
    sleep(0)
    time_current = app.getTime()

template renderer_end(): untyped =
  engine.target.render_end(app.settings.vsync)
  if app.settings.vsync == 0:
    app.sleep(1/app.settings.fps)
