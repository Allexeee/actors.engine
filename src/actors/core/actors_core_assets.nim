{.used.}

import ../vendor/actors_stb_image
from actors_core_app import app


type TImage* = object
  width*: cint
  height*: cint
  channels*: cint
  data*: seq[byte]


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


 