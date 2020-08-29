{.used.}

type
  LayerId* = distinct byte

  FpsCounter* = object
    updates* : float
    updates_last* : float
    frames*  : float
    frames_last* : float
  
  AppStats* = object
    updates* : int
    frames*  : int
  
  AppMeta* = object
    screen_size* : tuple[width: int, height: int]
    name*        : string
    assets_path* : string

  AppSettings* = object
    #display_size* : tuple[width: int, height: int]
    screen_size*  : tuple[width: int, height: int]
    path_shaders* : string
    path_assets*  : string
    fps*       : float32
    ups*       : float32
    name*      : string
    vsync*     : int32
  
  AppTime* = ref object
    seconds*        : float
    frames*         : float
    updates*        : float
    lag*            : float
    last*           : float
    counter*        : FpsCounter

  App* = ref object
    meta*     : AppMeta
    settings* : AppSettings
    time*     : AppTime
  
  ActionOnLayer* = proc(layer: LayerId)
  
  ILayer* = object
    Change*: proc (self: LayerId)



let app* = App()
var stats* = AppStats()
var a_layer_added* = newSeq[ActionOnLayer]()
var a_layer_changed* = newSeq[ILayer]()
var highest_layer_id*  = 0
var layer_current* = 0
var layer* = 0.LayerId



app.settings = AppSettings()
app.time = AppTime()

