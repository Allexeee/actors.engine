{.experimental: "codeReordering".}
#@head
import parsecfg
from os import fileExists


import actors/actors_engine as engine
import actors/actors_components as components

export engine except
  app

export components except
  used


components.used() # ugly hack

# import actors/actors_utils
# import actors/actors_backend as backend
# import actors/actors_core
# import actors/actors_math
# import actors/actors_graphics

# export actors_core except
#   app 
# export actors_math
# export actors_graphics
# export actors_utils

#@app
const have_settings = fileExists("settings.ini")


var onTick* : proc(d:float)
var onStart*: proc()


#@logic
var config : Config
if have_settings:
  config = loadConfig("settings.ini") 
 




# proc add_layer*(this: App, state: ApplayerState = Visible): IndexApplayer =
#   var id {.global.} = 0
#   let layers = app.get_layers_ptr()
#   layers[].add(AppLayer(id: id, state: state))
#   result = id.IndexAppLayer; id+=1


# proc set_events*(this: IndexScene, start: Action, tick: ActionT[float], stop: Action)=
#   set_events(this,(start,tick,stop))
# proc set_events*(this: IndexScene, events: ObjectEvents)=
#   let scenes = app.get_scenes_ptr()
#   scenes[this.int].events = events;

# proc set_scene*(this: IndexApplayer, id_scene: IndexScene)=
#   op_change_scene = Operation(kind: ChangeScene, cs_id_layer: this.int, cs_id_scene: id_scene.int)
# proc set_scene*(this: IndexScene)=
#   op_change_scene = Operation(kind: ChangeScene, cs_id_layer: 0, cs_id_scene: this.int)


proc run*(this: App) =
  engine.backend.start(this, this.settings.display_size, this.settings.name)
  onStart()
  update()
  engine.backend.dispose()

proc release*(this: App) =
  engine.backend.release()

proc update() {.discardable.} =
  while not engine.backend.shouldQuit():
    
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations()
    onTick(1/60f)
    engine.backend.updateImpl()
    
    #update_layers()
    #ops.setLen(0) 
    #op_scene()

# proc update_layers() {.discardable.} =
#   let layers = app.get_layers_ptr()
#   for i in 0..layers[].high:
#     var layer = addr layers[][i]
#     if layer.state == Visible:
#       layer.scene.events.tick(1/60f)  
 
#@logs
logSetMask {debug..benchmark}
if config != nil:
  log_add config.getSectionValue("log","name")
 

#@operations
#var ops = newSeq[Operation](0)
#var op_change_scene = Operation(kind: ChangeScene, cs_id_scene: -1, cs_id_layer: -1) 

# proc op_scene_first_time()=
#   let layers = app.get_layers_ptr()
#   let scenes = app.get_scenes_ptr()
#   let layer = addr layers[0]
#   let scene = addr scenes[0]
#   layer[].scene = scene
#   layer[].scene.events.start()

# proc op_scene()=
#   let op = addr op_change_scene
#   if op.cs_id_layer == -1:
#     return
#   let layers = app.get_layers_ptr()
#   let scenes = app.get_scenes_ptr()
#   let layer = addr layers[op.cs_id_layer]
#   let scene = addr scenes[op.cs_id_scene]
#   layer[].scene.events.stop()
#   layer[].scene = scene
#   layer[].scene.events.start()    
#   op.cs_id_layer = -1


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

