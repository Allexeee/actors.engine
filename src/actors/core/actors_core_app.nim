{.used.}
from actors_core_input import Input, InputIndex, addInput

type AppSettings* = object 
  name*         : string
  fps*          : float32
  display_size* : tuple[width: int, height: int]
  screen_size*  : tuple[width: int, height: int]
  path_shaders* : string
  path_assets*  : string

type App* = ref object
  settings*: AppSettings
  input*   : InputIndex
  #private
  inputs   : seq[Input]

let app* = App()
app.input = addInput()

proc getApp*(): App {.inline.} = app