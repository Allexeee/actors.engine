{.used.}
{.experimental: "codeReordering".}

import ../../px_h
import ../../px_plugins
import ../../px_tools
import ../px_math

const 
 MAX_QUADS    = 1_000_000
 MAX_VERTICES = MAX_QUADS * 4
 MAX_INDICES  = MAX_QUADS * 6


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

type PXenum* = GLenum

const
  PX_LINEAR*          : PXenum = GL_LINEAR
  PX_NEAREST*         : PXenum = GL_NEAREST
  PX_REPEAT*          : PXenum = GL_REPEAT
  PX_CLAMP_TO_BORDER* : PXenum = GL_CLAMP_TO_BORDER
  PX_CLAMP_TO_EDGE*   : PXenum = GL_CLAMP_TO_EDGE
  PX_REPEAT_MIRRORED* : PXenum = GL_MIRRORED_REPEAT
  PX_RGB*             : PXenum = GL_RGB8
  PX_RGBA*            : PXenum = GL_RGBA


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@shaders
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
const vert_default: cstring = """
  #version 330 core
  layout (location = 0) in vec3 aPos;
  void main()
  {
      gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
  } """
const frag_default: cstring = """
  #version 330 core
  out vec4 FragColor;
  void main()
  {
      FragColor=vec4(1,.5f,.2f,1);
  } """

var shaders* = newSeq[ShaderIndex]()
template `$`*(this: ShaderIndex): uint32 = this.uint32

template px_get_shader_log(obj: uint32, errType: ShaderCompileType): untyped =
  when defined(debug):
    block:
      let error {.inject.} = $errType
      var success {.inject.}: Glint
      var messageBuffer {.inject.} = newSeq[cchar](1024)
      var len {.inject.} : int32 = 0
      if errType == PROGRAM_INFO:
          glGetProgramiv(obj, GL_LINK_STATUS, success.addr)
          if success != GL_TRUE.ord:
              glGetProgramInfoLog(obj, 1024, len.addr, messageBuffer[0].addr)
              var message {.inject.}= ""
              if len!=0:
                  message = toString(messageBuffer,len)
              logError &"Type: {error} Message: {message}"
              quit()
      else:
          glGetShaderiv(obj, GL_COMPILE_STATUS, success.addr);
          if success != GL_TRUE.ord:
              glGetShaderInfoLog(obj, 1024, len.addr, messageBuffer[0].addr)
              var message {.inject.}= ""
              if len!=0:
                  message = toString(messageBuffer,len)
              logError &"Type: {error} Message: {message}"
              quit()

proc use*(self: ShaderIndex) =
  var inUse {.global.} : ShaderIndex
  if self.int == inuse.int: return
  inuse = self
 # mxid = glGetUniformLocation(self.GLuint,"mx_model")
  glUseProgram(self.GLuint) 

proc getShader*(db: DataBase, shader_path: string): ShaderIndex =    
    var path: string
    var vertCode = vertDefault
    var fragCode = fragDefault
    var geomCode = default(cstring)
    var id : uint32 = 0

    path = app.meta.assets_path & "shaders/" & shader_path & ".vert"

    if not fileExists(path):
        logWarn &"The path {path} for vertex shader doesn't exist, adding a default shader"
    else:
        vertCode = readFile(path)
    ##fragment
    path = app.meta.assets_path & "shaders/" & shader_path & ".frag"
    if not fileExists(path):
        logWarn &"The path {path} for fragment shader doesn't exist, adding a default shader"
    else:
        fragCode = readFile(path)
    ##geometry
    path = app.meta.assets_path & "shaders/" & shader_path & ".geom"
    if fileExists(path):
        geomCode = readFile(path)

    ##compile
    var vertex : Gluint = 0
    var fragment: Gluint = 0
    var geom: GLuint = 0
    ##vertex
    vertex = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(vertex,1, vert_code.addr, nil)
    glCompileShader(vertex)
    px_get_shader_log(vertex, VERTEX_INFO)
    ##fragment
    fragment = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragment,1'i32,frag_code.addr, nil)
    glCompileShader(fragment)
    px_get_shader_log(fragment, FRAGMENT_INFO)
    ##geom
    if geom_code!=default(cstring):
       geom = glCreateShader(GL_GEOMETRY_SHADER)
       glShaderSource(geom, 1'i32,geom_code.addr, nil)
       glCompileShader(geom)
       px_get_shader_log(geom, GEOMETRY_INFO)
    ##program
    id = glCreateProgram()
    glAttachShader(id,vertex)
    glAttachShader(id,fragment)
    if geom_code!=default(cstring):
        glAttachShader(id,geom)
    glLinkProgram(id)
    px_get_shader_log(id, PROGRAM_INFO)
    glDeleteShader(vertex)
    glDeleteShader(fragment)
    shaders.add(id.ShaderIndex)
    result = id.ShaderIndex

proc setSampler*(this: ShaderIndex, name: cstring, count: GLsizei, arg: ptr uint32) {.inline.} =
   glUniform1iv(glGetUniformLocation(this.GLuint,name),count, cast[ptr Glint](arg))

proc setBool*(this: ShaderIndex, name: cstring, arg: bool) {.inline.} =
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setInt*(this: ShaderIndex, name: cstring, arg: int) {.inline.} =
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setFloat*(this: ShaderIndex, name: cstring, arg: float32) {.inline.} =
  glUniform1f(glGetUniformLocation(this.GLuint,name),arg)

proc setVec*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setVec3*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  glUniform3f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z)

proc setColor*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setMatrix*(this: ShaderIndex, name: cstring, arg: var Matrix) {.inline.} =
  glUniformMatrix4fv(glGetUniformLocation(this.GLuint,name), 1, false, arg.e11.addr)

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@db
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
proc getTexture(db: DataBase, path: string, mode_rgb: PXenum, mode_filter: PXenum, mode_wrap: PXenum): tuple[id: TextureIndex, w: int, h: int] =
  var w,h,bits : cint
  var textureID : GLuint
  stbi_set_flip_vertically_on_load(true.ord)
  var data = stbi_load(app.meta.assets_path & path, w, h, bits, 0)
  var reason = $stbi_failure_reason()
  if reason != "no SOI": #png file  always gives this error. it's ok
    log $stbi_failure_reason()
  glCreateTextures(GL_TEXTURE_2D, 1, textureID.addr)
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode_wrap.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode_wrap.Glint)
  glTexImage2D(GL_TEXTURE_2D, 0, mode_rgb.Glint, w, h, 0, mode_rgb.Glenum, GL_UNSIGNED_BYTE, data)
  stbi_image_free(data)
  (textureID.TextureIndex,w.int,h.int)

proc getSprite (db: DataBase, texture: tuple[id: TextureIndex, w: int, h: int], shader: ShaderIndex) : Sprite =
  result = Sprite()

  result.texId = texture.id.uint32
  result.shader = shader
  result.quad = quad(0.0f,0.0f,vec(1,1,1,1),texture.id.cfloat)
  result.w = texture.w.float32
  result.h = texture.h.float32
  result.x = result.w/app.meta.ppu
  result.y = result.h/app.meta.ppu
  
  #res
  shader.use()
  var vbo : uint32
  var ebo : uint32
  glGenVertexArrays(1, result.quad.vao.addr)
  glGenBuffers(1, vbo.addr)
    
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, 4*sizeof(Vertex), result.quad.verts[0].addr, GL_STATIC_DRAW)

  glBindVertexArray(result.quad.vao)
  
  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))
  glEnableVertexAttribArray(0)

  glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  glEnableVertexAttribArray(1)
  
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
  glEnableVertexAttribArray(2)
  
  glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))
  glEnableVertexAttribArray(3)
  
  var indices = @[
     1'u32, 3'u32, 0'u32, 2'u32, 3'u32,1'u32
  ]
  
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);
  glBindTextureUnit(1, result.texID)

proc getSprite*(db: DataBase, filename: string, shader: ShaderIndex) : Sprite {.inline.} =
  db.getSprite(db.getTexture(filename,PX_RGBA, PX_NEAREST, PX_REPEAT),shader)


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@2d
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
proc draw*(self: Sprite, x,y,z: float, w,h: float, rotate: float) {.inline.} = draw(self,vec(x,y,z),vec(w,h), rotate)
var calc : bool = false
var model : Matrix = matrix()
proc draw*(self: Sprite, pos: Vec, size: Vec, rotate: float) =
  self.shader.use()
 
  var model = matrix()
  let sizex = self.w.float32/app.meta.ppu * size.x
  let sizey = self.h.float32/app.meta.ppu * size.y

  model.scale(sizex,sizey,1)
  model.translate(vec(-sizex*0.5, -sizey*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x/app.meta.ppu,pos.y/app.meta.ppu,0,1)) 

  self.shader.setMatrix("mx_model",model)

  glBindTexture(GL_TEXTURE_2D, self.texId)
  glBindVertexArray(self.quad.vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))

  stats.sprites += 1
  stats.drawcalls += 1

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@3d
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
proc quad(x,y: cfloat, color: Vec, texID: cfloat): Quad {.discardable.} =
  const size = 1.0f

  tempQuad[0].color     = color
  tempQuad[0].position  = vec3(x,y,0f)
  tempQuad[0].texCoords = vec2(0.0f, 0.0f)
  tempQuad[0].texID     = texID
  

  tempQuad[3].color     = color
  tempQuad[3].position  = vec3(x+size, y, 0.0)
  tempQuad[3].texCoords = vec2(1.0, 0.0)
  tempQuad[3].texID     = texID


  tempQuad[2].color     = color
  tempQuad[2].position  = vec3(x+size, y+size, 0.0)
  tempQuad[2].texCoords = vec2(1.0, 1.0)
  tempQuad[2].texID     = texID


  tempQuad[1].color     = color
  tempQuad[1].position  = vec3(x, y+size, 0.0)
  tempQuad[1].texCoords = vec2(0.0, 1.0)
  tempQuad[1].texID     = texID
  
  result.verts = tempQuad


let GL_FLOAT = 0x1406.GLenum
let GL_FALSE = false

var tempQuad : array[4,Vertex]
var drawcalls* = 0
var drawcallsLast* = 0





const maxQuadCount = 1_000_000
const maxVertexCount = maxQuadCount * 4;
const maxIndexCount = maxQuadCount * 6;


var renderers = newSeq[DataRenderer]()
var spriteRenderer* : ptr DataRenderer

var quadCount*   : int = 0
var vertexCount* : int = 0
var indexCount*  : int = 0

var whiteTexture   : GLuint

var vboBatch : uint32 # vertex buffer 
var vaoBatch : uint32 # vertex array
var eboBatch : uint32 # element buffer

var vertBatch {.noinit.} : array[maxVertexCount,Vertex]
var textures {.noinit.}  : array[32,uint32]

#var cachedQuad : Quad

proc rendererRelease*() = discard

# proc drawQuad*(pos: Vec, size: Vec, rotate: float) =
#   let shader = shaders[0]
#   shader.use()
#   let sizex = 1f/app.meta.ppu*size.x
#   let sizey = 1f/app.meta.ppu*size.y
#   var model = matrix()
#   model.scale(sizex,sizey,1)
#   model.translate(vec(-sizex*0.5, -sizey*0.5 , 0, 1))
#   model.rotate(rotate.radians, vec_forward)
#   model.translate(vec(pos.x/app.meta.ppu,pos.y/app.meta.ppu,0,1)) 

#   shader.setMatrix("mx_model",model)
  
#   glBindTexture(GL_TEXTURE_2D, whiteTexture)
#   glBindVertexArray(cachedQuad.vao)
#   glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))

#   stats.sprites += 1
#   stats.drawcalls += 1


proc genWhiteTexture(texture: ptr uint32) {.inline.} =
  glCreateTextures(GL_TEXTURE_2D, 1, texture)
  glBindTexture(GL_TEXTURE_2D, texture[])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE.Glint)
  var color = 0xffffffff
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.Glint,1,1,0,GL_RGBA, GL_UNSIGNED_BYTE, color.addr)

#working


proc rendererInit*() =

  #cachedQuad = getQuad()

  glCreateVertexArrays(1,vaoBatch.addr)
  glBindVertexArray(vaoBatch)

  glCreateBuffers(1,vboBatch.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertBatch), nil, GL_DYNAMIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))

  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  
  glEnableVertexAttribArray(2)
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
  
  glEnableVertexAttribArray(3)
  glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))


  ## indices allows to reduce number of vertices for drawing a quad
  var indices {.noinit,global.} : array[maxIndexCount,uint32]
  var offset = 0'u32
#  1'u32, 3'u32, 0'u32, 2'u32, 3'u32,1'u32
  for i in countup(0,indices.high,6):
    indices[i+0] = 1 + offset
    indices[i+1] = 3 + offset
    indices[i+2] = 0 + offset

    indices[i+3] = 2 + offset
    indices[i+4] = 3 + offset
    indices[i+5] = 1 + offset
    # indices[i+0] = 0 + offset
    # indices[i+1] = 1 + offset
    # indices[i+2] = 2 + offset

    # indices[i+3] = 2 + offset
    # indices[i+4] = 3 + offset
    # indices[i+5] = 0 + offset
    offset += 4

  glCreateBuffers(1, eboBatch.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eboBatch)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices[0].addr, GL_STATIC_DRAW);
  
  #texture 1x1
  genWhiteTexture(whiteTexture.addr)

  textures[0] = whiteTexture
  for i in 1..<32:
    textures[i] = i.uint32

# proc rendererInit*() =
#   cachedQuad = getQuad()
  
#   ## indices allows to reduce number of vertices for drawing a quad
#   var indices {.noinit,global.} : array[maxIndexCount,uint32]
#   var offset = 0'u32
#   for i in countup(0,indices.high,6):
#     indices[i+0] = 0 + offset
#     indices[i+1] = 1 + offset
#     indices[i+2] = 2 + offset

#     indices[i+3] = 2 + offset
#     indices[i+4] = 3 + offset
#     indices[i+5] = 0 + offset
#     offset += 4

#   var buf : GLuint
#   glCreateBuffers(1,buf.addr)
#   glNamedBufferStorage(buf,sizeof(indices)+sizeof(vertBatch),nil, GL_DYNAMIC_STORAGE_BIT)
#   glNamedBufferSubData(buf,0,sizeof(indices),indices[0].addr)
#   glNamedBufferSubData(buf,sizeof(indices),sizeof(vertBatch),vertBatch[0].addr)

#   glCreateVertexArrays(1,vaoBatch.addr)
#   glBindVertexArray(vaoBatch)
  
#   glVertexArrayElementBuffer(vaoBatch, buf)
#   glVertexArrayVertexBuffer(vaoBatch, 0, buf, sizeof(indices), sizeof(Vertex).GLsizei)

#   glCreateBuffers(1,vboBatch.addr)
#   glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
#   glBufferData(GL_ARRAY_BUFFER, sizeof(vertBatch), nil, GL_DYNAMIC_DRAW)

#   glEnableVertexAttribArray(0)
#   glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))

#   glEnableVertexAttribArray(1)
#   glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  
#   glEnableVertexAttribArray(2)
#   glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
  
#   glEnableVertexAttribArray(3)
#   glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))

  

#   # glCreateBuffers(1, eboBatch.addr)
#   # glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eboBatch)
#   # glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices[0].addr, GL_STATIC_DRAW);
  
#   # texture 1x1
#   genWhiteTexture()

#   textures[0] = whiteTexture
#   for i in 1..<32:
#     textures[i] = i.uint32


var vertices : array[maxQuadCount*4,Vertex]

var vertId = 0



proc updatePos*(x,y: cfloat) =
  const size = 0.04f

  if vertId >= 4*10000:
    batchEnd()
    flush()
    batchBegin()
  
  var v  = vertBatch[0+vertId].addr
  var v2 = vertBatch[3+vertId].addr
  var v3 = vertBatch[2+vertId].addr
  var v4 = vertBatch[1+vertId].addr
  v.position   = vec3(x,y,0f)
  v2.position  = vec3(x+0.004f,y,0f)
  v3.position  = vec3(x+0.004f,y+0.004f,0f)
  v4.position  = vec3(x,y+0.004f,0f)
  vertId += 4

proc updatePose*(x,y: cfloat) =
  const size = 0.004f * 32f

  if vertId >= 4*10000:
    batchEnd()
    flush()
    batchBegin()
  
  var v  = vertBatch[0+vertId].addr
  var v2 = vertBatch[3+vertId].addr
  var v3 = vertBatch[2+vertId].addr
  var v4 = vertBatch[1+vertId].addr
  v.position.x = x
  v.position.y = y
  #v.position.z = 0
  v2.position.x = x + size
  v2.position.y = y
  
  v3.position.x = x + size
  v3.position.y = y + size

  v4.position.x = x
  v4.position.y = y + size
 # v.position   = vec3(x,y,0f)
 # v2.position  = vec3(x+size,y,0f)
#  v3.position  = vec3(x+size,y+size,0f)
#  v4.position  = vec3(x,y+size,0f)
  vertId += 4

proc updateAll*(x,y: cfloat, scale: cfloat = 1, ang: cfloat = 0) =
  const ddsize = 0.004f
  const ddsize2 = 0.002f

  if vertId >= 4*100000:
    batchEnd()
    flush()
    batchBegin()

  let dx = -ddsize2 * scale
  let dy = -ddsize2 * scale
  let w = ddsize * scale
  let h = w
  let ccos = cos(ang)
  let csin = sin(ang)

  let v  = vertBatch[0+vertId].addr
  let v2 = vertBatch[3+vertId].addr
  let v3 = vertBatch[2+vertId].addr
  let v4 = vertBatch[1+vertId].addr
  
  v.position.x  = x + dx * ccos - dy * csin
  v.position.y  = y + dx * csin + dy * ccos;
  v.position.z = 0

  v2.position.x = x + (dx+w) * ccos - dy * csin
  v2.position.y = y + (dx+w) * csin + dy * ccos;
  v2.position.z = 0

  v3.position.x = x + (dx+w) * ccos - (dy+h) * csin
  v3.position.y = y + (dx+w) * csin + (dy+h) * ccos;
  v3.position.z = 0
    
  v4.position.x = x + dx * ccos - (dy+h) * csin
  v4.position.y = y + dx * csin + (dy+h) * ccos;
  v4.position.z = 0
  
  vertId += 4


proc makeQuad*(x,y: cfloat, color: Vec, texID: cfloat) {.discardable.} =
  const size = 0.008f

  if vertId >= 4*10000:
    batchEnd()
    flush()
    batchBegin()

  #var v = vertBatch[0+vertId].addr
  vertBatch[0+vertId].position  = vec3(x,y)
  vertBatch[0+vertId].color     = color
 #v.texCoords = vec2(0.0f, 0.0f)
  vertBatch[0+vertId].texID     = texID
  
#  var v2 = vertBatch[3+vertId].addr
  vertBatch[3+vertId].position  = vec3(x+size, y)
  vertBatch[3+vertId].color     = color
  #v.texCoords = vec2(1.0, 0.0)
  vertBatch[3+vertId].texID     = texID

  #var v3 = vertBatch[2+vertId].addr
  vertBatch[2+vertId].position  = vec3(x+size, y+size)
  vertBatch[2+vertId].color     = color
 #v.texCoords = vec2(1.0, 1.0)
  vertBatch[2+vertId].texID     = texID

  #var v4 = vertBatch[1+vertId].addr
  vertBatch[1+vertId].addr.position  = vec3(x, y+size)
  vertBatch[1+vertId].addr.color     = color
 # v.texCoords = vec2(0.0, 1.0)
  vertBatch[1+vertId].addr.texID     = texID
  vertId += 4


proc batchBegin*()=
  #echo stats.drawcalls
  vertId = 0#stats.drawcalls*10000

proc batchEnd*()=
 # let amount = vertId.GLint
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
 # echo amount
  glBufferSubData(GL_ARRAY_BUFFER,0,vertId*sizeof(Vertex),vertBatch[0].addr)

proc flush*() =
  let amount = (vertId / 4).GLint
  shaders[0].use()
  var model = matrix()

  shaders[0].setMatrix("mx_model",model)

  glBindTexture(GL_TEXTURE_2D, whiteTexture)
  glBindVertexArray(vaoBatch)
  glDrawElements(GL_TRIANGLES, amount*6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))
  vertId = 0
  stats.drawcalls+=1
  stats.sprites += amount