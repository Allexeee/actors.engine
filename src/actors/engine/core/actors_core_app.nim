import a_core_types
import ../../actors_utils

proc addLayer* (this: App): Layer =
  result        = Layer()
  result.ecs    = SystemEcs()
  result.ecs.layer = result
  result.update = SystemUpdate()
  result.update.layer = result
  result.time = SystemTime()
  result.time.scale = 1
  this.layers.add(result)

proc setActive* (layer: Layer) =
  app.layersActive.add(layer)

proc setInactive* (layer: Layer) =
  app.layersActive.remove(layer)

proc addTick*[T](this: Layer, obj: T) =
  this.update.ticks.add(obj.getTick)
