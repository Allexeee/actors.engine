import ../actors_types


var getTime: proc(): float

proc setProcs*(getTimeImpl: proc) =
  getTime = getTimeImpl


template clampUpdate*(code: untyped): untyped =
  let time_now = getTime()
  app.time.lag += time_now - app.time.last
  app.time.last = time_now
  
  while app.time.lag >= ms_per_update:
    code
    app.time.lag -= ms_per_update
    app.time.updates += 1
    app.time.counter.updates += 1
  
  if getTime() - app.time.seconds > 1.0:
    app.time.seconds += 1
    app.time.counter.updates_last = app.time.counter.updates
    app.time.counter.frames_last  = app.time.counter.frames
    app.time.counter.updates = 0
    app.time.counter.frames  = 0

template ms_per_update*(): float =
  1 / app.settings.ups

template framerate*(app: App): float =
  app.time.frames / app.time.seconds

template framerate_last*(app: App): float =
  app.time.counter.frames_last
template ups_last*(app: App): float =
  app.time.counter.updates_last


