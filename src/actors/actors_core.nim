{.experimental: "codeReordering".}
{.used.}
#@Head

import core/actors_core_base
import core/actors_core_app
import core/actors_core_assets
import core/actors_core_ecs
import core/actors_core_input

export actors_core_base
export actors_core_app
export actors_core_assets
export actors_core_ecs
export actors_core_input




# type
#   ComponentScene* = object
#     events*: ObjectEvents

#   TagEnabled* = object
  
 


# ecs.add ComponentScene, Compact
# ecs.add TagEnabled, Compact

# ecs.group scenes:
#     comps: ComponentScene; TagEnabled
#     scope: public
#     layer: lr_ecs_core

# scenes.handle:
#   for e in added:
#     e.cScene.events.start()
#     discard
#   for e in removed:
#     e.cScene.events.stop()
#     discard

# proc update*() =
#   backend.updateImpl()

#   for e in scenes:
#     let cScene = e.cScene
#     cScene.events.tick(1/60f)


# proc addScene*(this: App, events: ObjectEvents): IndexScene =
#   let e = entity(lr_ecs_core)
#   let cScene = e.add CScene
#   e.add TEnabled
#   cScene.events = events
#   result = e.id.IndexScene

# proc stop*(this: IndexScene) =
#   let e = (this.uint32,0'u32)
#   e.remove TEnabled


















  #this.remove TEnabled
# let e = entity()
# var cc = e.cScene
#ecs.add ComponentHealth, Compact

# proc addScene*(this: App): IndexScene =
#   let scenes = app.getScenes()
#   scenes[].add(Actor())
#   result = id_next_scene.IndexScene; id_next_scene+=1

# proc addScene*(): IndexScene =
#   result = id_next_scene.IndexScene; id_next_scene+=1

 
