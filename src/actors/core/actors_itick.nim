type ITick* = object
  tick*: proc (dt: float)

proc getITick*[T](this: T): ITick =
   ITick(tick: proc (dt: float) = this.tick(dt))