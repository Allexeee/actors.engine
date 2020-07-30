import a_core_types

proc addLayer* (this: App): Layer =
  result        = Layer()
  result.ecs    = SystemEcs()
  result.ecs.layer = result
  result.update = SystemUpdate()
  result.update.layer = result
  this.layers.add(result)

