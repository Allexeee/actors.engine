import actors/actors_engine  as engine
import actors/actors_runtime as runtime
import actors/actors_utils   as utils

export engine
export runtime
export utils

engine.core.pressKey         = engine.target.pressKeyImpl
engine.core.pressMouse       = engine.target.pressMouseImpl 
engine.core.getMousePosition = engine.target.getMousePositionImpl

let app* = App()
app.settings = AppSettings()

let layerApp* = app.addLayer()
layerApp.entity()




addInput()



# template start*(this: App, code: untyped): untyped =
#   this.start()
#   code

proc start*(this: App) {.inline.} =
  engine.target.start(this.settings.display_size, this.settings.name)

template run*(this: App, code: untyped): untyped =
  discard
# template run*(this: App, code: untyped): untyped =
#   var dt {.inject, used.} = 1/this.settings.fps
#   var input {.inject, used.} = app.input
#   while not engine.platform.shouldQuit():
#     ecs.process_operations(lr_ecs_core.int)
#     ecs.process_operations(lr_ecs_main.int)
#     for i in 0..layers.high:
#       var layer = layers[i]
#       var updater = layer.updater
#       for ii in 0..updater.ticks.high:
#         updater.ticks[ii].tick(dt)          
#     code
#     engine.platform.updateImpl()
#   engine.platform.dispose()