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
  var input {.inject, used.} = app.input
  while not engine.backend.shouldQuit():
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations()
    code
    engine.backend.updateImpl()
  engine.backend.dispose()

template close*(this: App, code: untyped): untyped =
  code

proc quit*(this: App) =
  engine.backend.release()


#@logs
import parsecfg
from os import fileExists

logSetMask {debug..benchmark}

const have_settings = fileExists("settings.ini")
 
if have_settings:
  var config = loadConfig("settings.ini") 
  log_add config.getSectionValue("log","name")
 
