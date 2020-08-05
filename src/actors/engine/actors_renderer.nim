{.used.}
import actors_types
import actors_math
import ../actors_utils

when defined(renderer_opengl):
  import platforms/renderer/actors_opengl
  export actors_opengl


type Vertexa* = object
  position*: Vec3
  color*: Vec
  texCoords*: Vec2
  texID* : cfloat
proc createVertex1*() : Vertexa =
  result = Vertexa(
    position : (0.0f,0.0f,0.0f),
    color : (0.15f, 0.5f, 0.95f, 1.0f),
    texCoords: (0f,0f),
    texID: (0f)
  )
proc createVertex2*() : Vertexa =
  result = Vertexa(
    position : (1.0f,0.0f,0.0f),
    color : (0.15f, 0.5f, 0.95f, 1.0f),
    texCoords: (1f,0f),
    texID: (0f)
  )
proc createVertex3*() : Vertexa =
  result = Vertexa(
    position : (1.0f,1.0f,0.0f),
    color : (0.15f, 0.5f, 0.95f, 1.0f),
    texCoords: (1f,1f),
    texID: (0f)
  )
proc createVertex4*() : Vertexa =
  result = Vertexa(
    position : (0.0f,1.0f,0.0f),
    color : (0.15f, 0.5f, 0.95f, 1.0f),
    texCoords: (0f,1f),
    texID: (0f)
  )

# proc createVertex1*() : Vertexa =
#   Vertexa(data : [0.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 0.0f, 0f])
# proc createVertex2*() : Vertexa =
#   Vertexa(data : [1.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 0.0f, 0f])
# proc createVertex3*() : Vertexa =
#   Vertexa(data : [1.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 1.0f, 0f])
# proc createVertex4*() : Vertexa =
#   Vertexa(data : [0.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 1.0f, 0f])  

# proc createVertex1*() : Vertexa =
#   [0.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 0.0f, 0f]
# proc createVertex2*() : Vertexa =
#   [1.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 0.0f, 0f]
# proc createVertex3*() : Vertexa =
#   [1.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 1.0f, 0f]
# proc createVertex4*() : Vertexa =
#   Vertexa(data : [0.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 1.0f, 0f])  


proc createQuad*(x,y: cfloat, texID: cfloat): seq[Vertex] {.discardable.} =
  const size = 1.0f
  result = newSeq[Vertex](4)
  result[0].color     = vec(0.15f, 0.5f, 0.95f, 1.0f)
  result[0].position  = vec3(x,y,0f)
  result[0].texCoords = vec2(0.0f, 0.0f)
  result[0].texID     = texID
  

  result[1].color     = vec(0.15, 0.5, 0.95, 1.0)
  result[1].position  = vec3(x+size, y, 0.0)
  result[1].texCoords = vec2(1.0, 0.0)
  result[1].texID     = texID


  result[2].color     = vec(0.15, 0.5, 0.95, 1.0)
  result[2].position  = vec3(x+size, y+size, 0.0)
  result[2].texCoords = vec2(1.0, 1.0)
  result[2].texID     = texID


  result[3].color     = vec(0.15, 0.5, 0.95, 1.0)
  result[3].position  = vec3(x, y+size, 0.0)
  result[3].texCoords = vec2(0.0, 1.0)
  result[3].texID     = texID

proc createQuadd*(x,y: cfloat, texID: cfloat): pointer {.discardable.} =
  const size = 1.0f
  var r = newSeq[Vertex](4)
  r[0].color     = vec(0.15f, 0.5f, 0.95f, 1.0f)
  r[0].position  = vec3(x,y,0f)
  r[0].texCoords = vec2(0.0f, 0.0f)
  r[0].texID     = texID
  

  r[1].color     = vec(0.15, 0.5, 0.95, 1.0)
  r[1].position  = vec3(x+size, y, 0.0)
  r[1].texCoords = vec2(1.0, 0.0)
  r[1].texID     = texID


  r[2].color     = vec(0.15, 0.5, 0.95, 1.0)
  r[2].position  = vec3(x+size, y+size, 0.0)
  r[2].texCoords = vec2(1.0, 1.0)
  r[2].texID     = texID


  r[3].color     = vec(0.15, 0.5, 0.95, 1.0)
  r[3].position  = vec3(x, y+size, 0.0)
  r[3].texCoords = vec2(0.0, 1.0)
  r[3].texID     = texID
  
  r[0].addr

proc drawDebug*() = 
  discard

#export actors_renderer