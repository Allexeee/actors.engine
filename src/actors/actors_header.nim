type LayerId* = distinct uint32

type AppSettings* = object
  display_size* : tuple[width: int, height: int]
  screen_size*  : tuple[width: int, height: int]
  path_shaders* : string
  path_assets*  : string
  fps*       : float32
  ups*       : float32
  name*      : string
  vsync*     : int32

type App* = ref object
  settings* : AppSettings

let app* = App()
# app.time = AppTime()
# app.settings = AppSettings()
#   App* = ref object
#     settings*     : AppSettings
#     time*         : AppTime
#     layers*       : seq[Layer]
#     input*        : InputIndex
#     layersActive* : seq[Layer]