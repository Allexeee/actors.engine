{.used.}

import actors/a_engine as engine
export engine

import actors/a_runtime as runtime
export runtime


var layerMain* = newLayer()


var processorCamera = ProcessorCamera()
layerMain.updater.addTick(processorCamera)



#var lmain = layers[0]


#var ticks = newSeq[ITick](100)


# type
#   ITick* = concept var x
#     x.tick(float)
#type ActionTY*[T,Y] = proc(arg: T, arg2: Y){.nimcall.}
# type ProcessorCamera = ref object
#  # ticke: Acta[ITick,float]
#   id: int
# type ITick = object
#   tick: proc (dt: float)


# proc newProcCamera : ProcessorCamera =
#   result = new ProcessorCamera
#   result.id = 100

# var processorCamera = newProcCamera()


# proc tick*(this: ProcessorCamera, dt: float) =
#   discard




# var ticks = newSeq[ITick]()

# # ticks.add(!!processorCamera)


# # ticks[0].tick(21)

# var itick = processorCamera.getITick()


# profile.start "interface": 
#   for i in 0..10000000:
#     itick.tick(0)
# profile.start "procs": 
#   for i in 0..10000000:
#     processorCamera.tick(0)

# log profile
#var pooo = doTick[ProcessorCamera]
# processorCamera.id = 100
# processorCamera.ticker = tick



# var ticks = newSeq[]()
# ticks.add(processorCamera.ticker)


#ticks[0](0)

# proc update(tickable: ITick, dt: float) =
#   tickable.tick(dt)




#type ActionTY*[T,Y] = proc(arg: T, arg2: Y){.nimcall.}
#var poo = update[ProcessorCamera]

#poo(processorCamera,9)
# var aa : ActionTY[ITicker,float] = ticka

# aa(processorCamera,10)

#type ActorCamera* = ref object

 


template start*(this: App, code: untyped): untyped =
  this.start()
  code

proc start*(this: App) {.inline.} =
  engine.platform.start(this.settings.display_size, this.settings.name)


template run*(this: App, code: untyped): untyped =
  var dt {.inject, used.} = 1/this.settings.fps
  var input {.inject, used.} = app.input
  while not engine.platform.shouldQuit():
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations(lr_ecs_main.int)
    for i in 0..layers.high:
      var layer = layers[i]
      var updater = layer.updater
      for ii in 0..updater.ticks.high:
        updater.ticks[ii].tick(dt)          
    code
    engine.platform.updateImpl()
  engine.platform.dispose()

template close*(this: App, code: untyped): untyped =
  code

proc quit*(this: App) =
  engine.platform.release()


#@logs
import parsecfg
from os import fileExists

logSetMask {debug..benchmark}

const have_settings = fileExists("settings.ini")
 
if have_settings:
  var config = loadConfig("settings.ini") 
  log_add config.getSectionValue("log","name")
 
