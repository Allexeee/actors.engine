{.used.}
import actors_types
import actors_math
import ../actors_utils

when defined(renderer_opengl):
  import platforms/renderer/actors_opengl
  export actors_opengl



proc createQuad*(x,y: float, texID: float): array[4,Vertex] {.discardable.} =
  const size = 1.0
  
  result[0].position  = (x, y, 0.0)
  result[0].color     = (0.15, 0.5, 0.95, 1.0)
  result[0].texCoords = (0.0, 0.0)
  result[0].texID     = texID
   

  result[1].position  = (x+size, y, 0.0)
  result[1].color     = (0.15, 0.5, 0.95, 1.0)
  result[1].texCoords = (0.0, 0.0)
  result[1].texID     = texID

 
  result[2].position  = (x+size, y+size, 0.0)
  result[2].color     = (0.15, 0.5, 0.95, 1.0)
  result[2].texCoords = (0.0, 0.0)
  result[2].texID     = texID
 
 
  result[3].position  = (x, y+size, 0.0)
  result[3].color     = (0.15, 0.5, 0.95, 1.0)
  result[3].texCoords = (0.0, 0.0)
  result[3].texID     = texID

proc drawDebug*() = 
  discard

#export actors_renderer