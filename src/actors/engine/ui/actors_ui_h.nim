#import ../actors_input

type UI* = ref object of RootObj
  show* : bool
  base* : UI

var uis* = newSeq[UI]()

method draw*(self: UI) {.base,  locks: "unknown".} = 
  discard