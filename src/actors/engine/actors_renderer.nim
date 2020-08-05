{.used.}
import actors_types
import actors_math
import ../actors_utils
import ../vendor/actors_stb_image

when defined(renderer_opengl):
  import platforms/renderer/actors_opengl
  export actors_opengl

var tempQuad : array[4,Vertex]


proc drawQuad*(x,y: cfloat, color: Vec, texID: cfloat): pointer {.discardable.} =
  const size = 1.0f
  
  tempQuad[0].color     = color
  tempQuad[0].position  = vec3(x,y,0f)
  tempQuad[0].texCoords = vec2(0.0f, 0.0f)
  tempQuad[0].texID     = texID
  

  tempQuad[1].color     = color
  tempQuad[1].position  = vec3(x+size, y, 0.0)
  tempQuad[1].texCoords = vec2(1.0, 0.0)
  tempQuad[1].texID     = texID


  tempQuad[2].color     = color
  tempQuad[2].position  = vec3(x+size, y+size, 0.0)
  tempQuad[2].texCoords = vec2(1.0, 1.0)
  tempQuad[2].texID     = texID


  tempQuad[3].color     = color
  tempQuad[3].position  = vec3(x, y+size, 0.0)
  tempQuad[3].texCoords = vec2(0.0, 1.0)
  tempQuad[3].texID     = texID
  
  tempQuad[0].addr


proc sprite*(filename: string) : Sprite =
  stbi_set_flip_vertically_on_load(true.ord)
  discard

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