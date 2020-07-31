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


template run*(app: App, code: untyped): untyped =
  engine.target.start(app.settings.display_size, app.settings.name)
  app.time.lag  = 0
  app.time.last = app.getTime()
  var vsync_toggle : bool 
  engine.target.setVSync(app.settings.vsync)
  while not engine.target.shouldQuit():
    if vsync_toggle != app.settings.vsync_toggle:
      vsync_toggle = app.settings.vsync_toggle
      if vsync_toggle:
        app.settings.vsync = 1
      else: app.settings.vsync = 0
      engine.target.setVSync(app.settings.vsync)
    engine.target.pollEvents()

    clampUpdate():
      for layer in app.layersActive:
        layer.ecs.execute()
        for tickable in layer.update.ticks:
          tickable.tick(layer)
      code

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    if app.settings.vsync == 1:
      glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
    else:
      glClearColor(0.2f, 0.4f, 0.3f, 1.0f)
    render()

    app.time.frames += 1
    app.time.counter.frames += 1
    renderer_end()
    
  
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
  
  
# template render_end(): untyped =
  
#   discard