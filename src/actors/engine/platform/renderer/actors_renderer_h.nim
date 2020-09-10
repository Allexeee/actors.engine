import ../../../actors_h
import ../../../actors_tools
import ../../actors_math

when defined(renderer_opengl):
  include actors_opengl_h

const MAX_QUADS    = 1_000_000
const MAX_VERTICES = MAX_QUADS * 4
const MAX_INDICES  = MAX_QUADS * 6

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
  w*,h* : float32
  x*,y* : float32
  shader*  : ShaderIndex
  texId*    : uint32

type DataRenderer* = object
  ## data for batch renderer
  vbo           : uint32 # vertex buffer
  vao           : uint32 # vertex array
  ibo           : uint32 # indices
  vertexCount   : uint32 # current vertex
  vertexBatch   : array[MAX_VERTICES,Vertex]
  vertexIndices : array[MAX_INDICES,uint32]
  textures      : array[32,uint32]
  textureWhite  : uint32


