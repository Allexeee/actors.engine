import ../../a_engine

{.used.}
type
  ProcessorUpdate* = ref object
    ticks* : seq[ITick] 

type
  Layer* = ref object of RootObj
    updater* : ProcessorUpdate

var layers* = newSeq[Layer]()

proc newLayer*(): Layer =
  result = Layer()
  result.updater = ProcessorUpdate()
  result.updater.ticks = newSeq[ITick]()
  layers.add(result)

proc addTick*[T](this: ProcessorUpdate, obj: T) =
  this.ticks.add(obj.getTick)
