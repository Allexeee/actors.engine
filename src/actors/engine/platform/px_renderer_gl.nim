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

proc setMat*(this: ShaderIndex, name: cstring, arg: var Matrix) {.inline.} =
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

#   result.texId = texture.id.uint32
#   result.shader = shader
#  # result.quad = quad(0.0f,0.0f,vec(1,1,1,1),texture.id.cfloat)
#   result.w = texture.w.float32
#   result.h = texture.h.float32
#   result.x = result.w/app.meta.ppu
#   result.y = result.h/app.meta.ppu
  
#   #res
#   shader.use()
#   var vbo : uint32
#   var ebo : uint32
#   glGenVertexArrays(1, result.quad.vao.addr)
#   glGenBuffers(1, vbo.addr)
    
#   glBindBuffer(GL_ARRAY_BUFFER, vbo)
#   glBufferData(GL_ARRAY_BUFFER, 4*sizeof(Vertex), result.quad.verts[0].addr, GL_STATIC_DRAW)

#   glBindVertexArray(result.quad.vao)
  
#   glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))
#   glEnableVertexAttribArray(0)

#   glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
#   glEnableVertexAttribArray(1)
  
#   glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
#   glEnableVertexAttribArray(2)
  
#   glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))
#   glEnableVertexAttribArray(3)
  
#   var indices = @[
#      1'u32, 3'u32, 0'u32, 2'u32, 3'u32,1'u32
#   ]
  
#   glGenBuffers(1, ebo.addr)
#   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
#   glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);
#   glBindTextureUnit(1, result.texID)

proc getSprite*(db: DataBase, filename: string, shader: ShaderIndex) : Sprite {.inline.} =
  db.getSprite(db.getTexture(filename,PX_RGBA, PX_NEAREST, PX_REPEAT),shader)

