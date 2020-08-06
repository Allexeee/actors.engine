import ../actors_types
import ../../actors_utils
import ../../vendor/actors_stb_image
#import ../../actors_internal

proc addLayer* (this: App): Layer =
  result        = Layer()
  result.ecs    = SystemEcs()
  result.ecs.layer = result
  result.update = SystemUpdate()
  result.update.layer = result
  result.time = SystemTime()
  result.time.scale = 1
  this.layers.add(result)

proc setActive* (layer: Layer) =
  app.layersActive.add(layer)

proc setInactive* (layer: Layer) =
  app.layersActive.remove(layer)

proc addTick*[T](this: Layer, obj: T) =
  this.update.ticks.add(obj.getTick)

proc calculate_aspect_ratio*(self: App): float =
  self.settings.display_size.width / self.settings.display_size.height

proc loadImage*(filename: string, desired_channels: int = 0): TImage =
  var width: cint
  var height: cint
  var components: cint
  
  stbi_set_flip_vertically_on_load(true.ord)
  let data = stbi_load(app.settings.path_assets & filename, width, height, components, desired_channels)
  let actual_channels = if desired_channels > 0: desired_channels else: components.int

  if data == nil:
      raise newException(STBIException, failureReason())

  # Copy pixel data
  var pixelData: seq[byte]

  newSeq(pixelData, width * height * actual_channels)
  copyMem(pixelData[0].addr, data, pixelData.len)

  stbi_image_free(data)

  result = TImage(
      width: width,
      height: height,
      channels: components,
      data: pixelData
  )

template path_assets*() : string =
  app.settings.path_assets