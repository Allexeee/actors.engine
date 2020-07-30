import a_core_types

proc addLayer* (this: App): Layer =
  result        = Layer()
  result.ecs    = SystemEcs()
  result.ecs.layer = result
  result.update = SystemUpdate()
  result.update.layer = result
  result.time = SystemTime()
  result.time.delta_cap = 1/this.settings.fps
  result.time.scale = 1
  this.layers.add(result)

proc addTick*[T](this: Layer, obj: T) =
  this.update.ticks.add(obj.getTick)
