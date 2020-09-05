{.used.}

type
  LayerId* = distinct byte

  DataBase* = ref object

  AppStats* = object
    updates* : int
    frames*  : int
  
  AppMeta* = object
    screenSize*  : tuple[width: int, height: int]
    fullScreen*  : bool
    showCursor*  : bool
    name*        : string
    assetsPath*  : string
    fps*         : float32
    ups*         : float32
    ppu*         : float32
    vsync*       : int32

  FpsCounter* = object
    updates*      : float
    updates_last* : float
    frames*       : float
    frames_last*  : float

  AppTime* = ref object
    dt*             : float
    seconds*        : float
    frames*         : float
    lag*            : float
    last*           : float
    counter*        : FpsCounter

  App* = ref object
    meta*     : AppMeta
    time*     : AppTime
 
  ActionOnLayer* = proc(layer: LayerId)

  ILayer* = object
    Change*: proc (self: LayerId)


#Time
let app* = App()
let db*  = DataBase()
var stats* = AppStats()
var a_layer_added* = newSeq[ActionOnLayer]()
var a_layer_changed* = newSeq[ILayer]()
var highest_layer_id*  = 0
var layer_current* = 0
var layer* = 0.LayerId
var tildaPressed* = false

#app.settings = AppSettings()
app.time = AppTime()

template MS_PER_UPDATE*():float =
  1/app.meta.ups

