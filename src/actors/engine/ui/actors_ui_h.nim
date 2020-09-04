{.used.}

type UiWindow* = ref object of RootObj
  show* : bool
  base* : UiWindow

method draw*(self: UiWindow) {.base,  locks: "unknown".} = 
  discard