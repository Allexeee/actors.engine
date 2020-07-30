import a_core_types

proc getITick*[T](this: T): ITick =
   ITick(tick: proc (dt: float) = this.tick(dt))

proc getIDispose*[T](this: T): IDispose =
  IDispose(dispose: proc() = this.dispose())