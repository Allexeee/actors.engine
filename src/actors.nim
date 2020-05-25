{.experimental: "codeReordering".}
#@head
import actors/actors_engine as engine
import actors/actors_components as components

export engine except
  app

export components except
  used


template start*(this: App, code: untyped): untyped =
  engine.backend.start(this, this.settings.display_size, this.settings.name)
  code

template run*(this: App, code: untyped): untyped =
  var dt {.inject, used.} = 1/this.settings.fps
  while not engine.backend.shouldQuit():
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations()
    code
    engine.backend.updateImpl()
  engine.backend.dispose()
# template start*(this: Profile,benchmarkName: string, code: untyped): untyped  =
#   block:
#     profileStart(benchmarkName)
#     code
#     profileEnd(benchmarkName) 

    #ecs.process_operations(lr_ecs_core.int)
    #ecs.process_operations()
    #onTick(1/60f)
    #engine.backend.updateImpl()

#components.used() # ugly hack


# var onTick* : proc(d:float)
# var onStart*: proc()
 
# proc run*(this: App) =
#   engine.backend.start(this, this.settings.display_size, this.settings.name)
#   #onStart()
#   update()
#   engine.backend.dispose()

proc release*(this: App) =
  engine.backend.release()

proc update() {.discardable.} =
  while not engine.backend.shouldQuit():
    
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations()
    #onTick(1/60f)
    engine.backend.updateImpl()

 
#@logs
import parsecfg
from os import fileExists

logSetMask {debug..benchmark}

const have_settings = fileExists("settings.ini")
 
if have_settings:
  var config = loadConfig("settings.ini") 
  log_add config.getSectionValue("log","name")
 
#@docs
#@docs app

# proc getApp*(): App
#   ## Retrieve the application object
#   ## holds settings and other useful data
#   ## 
#   ## .. code-block:: Nim
#   ##   let app = getApp()

# type
#   SceneTest* = object of RootObj
#     core* : Layer
#     main* : Layer

# proc add_layer*(this: App,state: ApplayerState = Visible): IndexApplayer
#   ## Register a new app layer
#   ## 
#   ## .. code-block:: Nim
#   ##   let lr_game = add_applayer()
# #proc add_scene*(this: App): IndexScene
#   ## Register a new scene
#   ## 
#   ## .. code-block:: Nim
#   ##   let sn_game = add_scene()

# proc set_events*(this: IndexScene, start: Action, tick: ActionT[float], stop: Action)
#   ## Start: runs once when scene become active
#   ## 
#   ## Tick: runs every frame
#   ## 
#   ## Stop: runs once when scene goes inactive
# proc set_events*(this: IndexScene, events: ObjectEvents)
#   ## Start: runs once when scene become active
#   ## 
#   ## Tick: runs every frame
#   ## 
#   ## Stop: runs once when scene goes inactive

# proc set_scene*(this: IndexApplayer, id_scene: IndexScene)
#   ## Switch scene for `this` layer
# proc set_scene*(this: IndexScene)
#   ## Switch scene for the default layer

