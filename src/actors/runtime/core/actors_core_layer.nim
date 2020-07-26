import ../../a_engine

{.used.}
type
  ProcessorUpdate* = ref object
    ticks* : seq[ITick] 


type
  Layer* = ref object of RootObj
    updater* : ProcessorUpdate


proc newLayer*(): Layer =
  result = Layer()
  result.updater = ProcessorUpdate()
  result.updater.ticks = newSeq[ITick]()
