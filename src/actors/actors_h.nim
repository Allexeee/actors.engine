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

  AppSettings* = object
    display_size* : tuple[width: int, height: int]
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





# import macros

# macro importString(path: static[string], alias: static[string]): untyped =
#   result = newNimNode(nnkImportStmt).add(
#     newNimNode(nnkInfix).add(
#       newIdentNode("as")
#     ).add(
#       newIdentNode(path)
#     ).add(
#       newIdentNode(alias)
#     )
#   )

# importString("strutils", alias="su")


# proc addLayer* (this: App): Layer =
#   result        = Layer()
#   result.ecs    = SystemEcs()
#   result.ecs.layer = result
#   result.update = SystemUpdate()
#   result.update.layer = result
#   result.time = SystemTime()
#   result.time.scale = 1
#   this.layers.add(result)

# proc setActive* (layer: Layer) =
#   app.layersActive.add(layer)

# proc setInactive* (layer: Layer) =
#   app.layersActive.remove(layer)

# proc addTick*[T](this: Layer, obj: T) =
#   this.update.ticks.add(obj.getTick)

# proc calculate_aspect_ratio*(self: App): float =
#   self.settings.display_size.width / self.settings.display_size.height

# proc loadImage*(filename: string, desired_channels: int = 0): TImage =
#   var width: cint
#   var height: cint
#   var components: cint
  
#   stbi_set_flip_vertically_on_load(true.ord)
#   let data = stbi_load(app.settings.path_assets & filename, width, height, components, desired_channels)
#   let actual_channels = if desired_channels > 0: desired_channels else: components.int

#   if data == nil:
#       raise newException(STBIException, failureReason())

#   # Copy pixel data
#   var pixelData: seq[byte]

#   newSeq(pixelData, width * height * actual_channels)
#   copyMem(pixelData[0].addr, data, pixelData.len)

#   stbi_image_free(data)

#   result = TImage(
#       width: width,
#       height: height,
#       channels: components,
#       data: pixelData
#   )

# template path_assets*() : string =

# var getTime: proc(): float

# proc setProcs*(getTimeImpl: proc) =
#   getTime = getTimeImpl


# template clampUpdate*(code: untyped): untyped =
#   let time_now = getTime()
#   app.time.lag += time_now - app.time.last
#   app.time.last = time_now
  
#   while app.time.lag >= ms_per_update:
#     code
#     app.time.lag -= ms_per_update
#     app.time.updates += 1
#     app.time.counter.updates += 1
  
#   if getTime() - app.time.seconds > 1.0:
#     app.time.seconds += 1
#     app.time.counter.updates_last = app.time.counter.updates
#     app.time.counter.frames_last  = app.time.counter.frames
#     app.time.counter.updates = 0
#     app.time.counter.frames  = 0

# template ms_per_update*(): float =
#   1 / app.settings.ups

# template framerate*(app: App): float =
#   app.time.frames / app.time.seconds

# template framerate_last*(app: App): float =
#   app.time.counter.frames_last
# template ups_last*(app: App): float =
#   app.time.counter.updates_last