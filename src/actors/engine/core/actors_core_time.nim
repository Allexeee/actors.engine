import a_core_types


var getTime*: proc(): float
var app* : App

template delta*(this: SystemTime): float =
  app.time.delta * this.scale

proc begin*(this: TimeApp) =
  this.lag = 0
  this.last = getTime()

template clampUpdate*(this: TimeApp, code: untyped): untyped =
  let time_now = getTime()
  let fps_limit = app.fps_limit
  let fps = app.settings.fps
  this.delta = clamp(time_now - this.last,0, fps_limit) 
  this.ticks += int((time_now - this.last) * fps)
  this.lag += (time_now - this.last) / fps_limit
  this.last = time_now
 
  while this.lag >= 1:
    code
    this.counter.updates+=1
    this.lag-=1
  this.counter.frames+=1
 


template countFPS*(this: TimeApp) =
  when defined(show_fps):
    this.counter.ms += this.delta * 1000
    if getTime() - this.counter.timer > 1.0:
        this.counter.timer += 1
        block:
          var fr {.inject.} = this.counter.frames
          var up {.inject.} = this.counter.updates
          var ms {.inject.} = this.counter.ms / (float)fr
          log &"fps: {fr}  ups: {up}  ms: {ms}"
        this.counter.updates = 0
        this.counter.frames  = 0
        this.counter.ms      = 0
  else:
    this.counter.updates = 0
    this.counter.frames  = 0

template fps_limit*(app: App): float =
  1 / app.settings.fps

template ms_per_update*(app: App): float =
  app.fpsCap * 1000

# proc ms*(app: App): float =
#   app.time.delta * 1000

