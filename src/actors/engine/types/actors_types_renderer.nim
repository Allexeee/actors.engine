import sets

import ../actors_math

type ShaderIndex* = distinct uint32

type ShaderCompileType*   = enum
  VERTEX_INFO = 0,
  FRAGMENT_INFO,
  GEOMETRY_INFO,
  PROGRAM_INFO
type ShaderLoadError*     = object of ValueError
type ShaderCompileError*  = object of ValueError



type Vertex* = object
  position* : Vec3
  color*    : Vec
  texCoords*: Vec2
  texID*    : cfloat

type Quad* = object
  verts*: ptr Vertex
  vbo  *: uint32

type Sprite* = object
  #quad* : Quad

