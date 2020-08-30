{.used.}

type UI* = ref object of RootObj
  show* : bool
  base* : UI

method draw*(self: UI) {.base,  locks: "unknown".} = 
  discard