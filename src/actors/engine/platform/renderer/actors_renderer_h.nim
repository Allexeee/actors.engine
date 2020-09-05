import ../../../actors_h
import ../../../actors_tools
import ../../actors_math

when defined(renderer_opengl):
  include actors_opengl_h

type ShaderIndex* = distinct uint32

type ShaderCompileType*   = enum
  VERTEX_INFO = 0,
  FRAGMENT_INFO,
  GEOMETRY_INFO,
  PROGRAM_INFO
type ShaderLoadError*     = object of ValueError

type ShaderCompileError*  = object of ValueError

type TextureIndex* = distinct uint32

type Vertex* = object
  position* : Vec3
  color*    : Vec
  texCoords*: Vec2
  texID*    : cfloat

type Quad* = object
  verts*: array[4,Vertex]
  vao  *: uint32

type Sprite* = ref object
  quad* : Quad
  x*,y* : float32
  shader*  : ShaderIndex
  texId*    : uint32

