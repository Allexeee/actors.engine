{.used.}
{.experimental: "codeReordering".}

import times
import os
import strformat
import actors/actors_engine  as engine
import actors/actors_runtime as runtime
import actors/actors_utils   as utils

export engine except app
export runtime
export utils

#var wait = proc(ms: float)

engine.core.getTime          = engine.target.getTimeImpl
engine.core.pressKey         = engine.target.pressKeyImpl
engine.core.pressMouse       = engine.target.pressMouseImpl 
engine.core.getMousePosition = engine.target.getMousePositionImpl

#var getTime = engine.core.getTime
#wait = engine.target.getMousePositionImpl


let app* = App()
app.time = TimeApp()
app.settings = AppSettings()

engine.core.app = app

let layerApp* = app.addLayer()
layerApp.entity()

let input* = app.addInput()

app.time.fromStart = engine.getTime()

proc getTime* (app: App) : float =
  engine.getTime()

template run*(app: App, code: untyped): untyped =
  engine.target.start(app.settings.display_size, app.settings.name)
  app.time.begin()

  while not engine.target.shouldQuit():
    app.time.clampUpdate():
      for layer in app.layersActive:
        layer.ecs.execute()
        for tickable in layer.update.ticks:
          tickable.tick(layer)
      code

    app.time.countFPS()
    engine.target.update()
    app.sleep(app.fps_limit)

  engine.target.dispose()


proc quit*(this: App) =
  engine.target.release()


proc sleep*(app: App, t: float) =
  var time_current = app.getTime()
  while time_current - app.time.last < t:
    sleep(0)
    time_current = app.getTime()
