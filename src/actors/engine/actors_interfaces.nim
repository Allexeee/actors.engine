# proc getTick*[T](this: T): ITick =
#    ITick(tick: proc (layer: Layer) = this.tick(layer))


# proc getDispose*[T](this: T): IDispose =
#   IDispose(dispose: proc() = this.dispose())