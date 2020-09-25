{.used.}
{.experimental: "codeReordering".}

import ../../px_h
import ../../px_plugins
import ../../px_tools
import    ../px_math
import       px_gl_h

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

type Mesh* = object
  verts*   : seq[Vertex]
  indices* : seq[uint32]
  vbo*     : uint32
  vao*     : uint32
  ibo*     : uint32

type SpriteBatch* = object
  mesh* : Mesh
  vertex_id* : uint32


type Vertex* = object
  position*   : Vec3
  color*      : Vec
  texcoords*  : Vec2
  texid* : GLfloat

type Quad* = object
  verts*: array[4,Vertex]
  vao  *: uint32

type Sprite* = ref object
  quad* : Quad
  w*,h* : float32
  x*,y* : float32
  shader*  : ShaderIndex
  texId*   : uint32

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

const SPRITES_PER_BATCH  = 20_000
const VERTICES_PER_BATCH = SPRITES_PER_BATCH * 4

var spritebatch  : SpriteBatch
var texturewhite : GLuint
var textures {.noinit.} : array[32,Glint]
var texture_next_id = 0
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

proc setSamplers*(this: ShaderIndex, name: cstring, count: GLsizei, arg: ptr Glint) {.inline.} =
   glUniform1iv(glGetUniformLocation(this.GLuint,name), count, arg)


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
  #echo glGetUniformLocation(this.GLuint,name), "        AAAAAAAAAAAAAAAAAAA"

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@db
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
var tempQuad : array[4,Vertex]
proc quad(x,y: cfloat, color: Vec, texID: cfloat): Quad {.discardable.} =
  const size = 1.0f

  tempQuad[0].color     = color
  tempQuad[0].position  = vec3(x,y,0f)
  tempQuad[0].texCoords = vec2(0.0f, 0.0f)
  tempQuad[0].texid     = texID
  

  tempQuad[3].color     = color
  tempQuad[3].position  = vec3(x+size, y, 0.0)
  tempQuad[3].texCoords = vec2(1.0, 0.0)
  tempQuad[3].texid     = texID


  tempQuad[2].color     = color
  tempQuad[2].position  = vec3(x+size, y+size, 0.0)
  tempQuad[2].texCoords = vec2(1.0, 1.0)
  tempQuad[2].texid     = texID


  tempQuad[1].color     = color
  tempQuad[1].position  = vec3(x, y+size, 0.0)
  tempQuad[1].texCoords = vec2(0.0, 1.0)
  tempQuad[1].texid     = texID
  
  result.verts = tempQuad

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
  glBindTexture(GL_TEXTURE_2D, 0)
  texture_next_id += 1
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
#@3d
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
let GL_FLOAT = 0x1406.GLenum
let GL_FALSE = false

proc get_mesh_quads*(total_quads: int): Mesh =
  let total_verts   = total_quads * 4
  let total_indices = total_quads * 6
  result.verts = newSeq[Vertex](total_verts)

  glCreateVertexArrays(1,result.vao.addr)
  glBindVertexArray(result.vao)

  glCreateBuffers(1,result.vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  
  glBufferData(GL_ARRAY_BUFFER, total_verts*sizeof(Vertex), nil, GL_DYNAMIC_DRAW)
  
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))
  
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  
  glEnableVertexAttribArray(2)
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texcoords)))
  
  glEnableVertexAttribArray(3)
  glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texid)))

  result.indices = newSeq[uint32](total_indices)
  let indices = result.indices.addr
  var offset  = 0'u32
  for i in countup(0,indices[].high,6):
    indices[][i+0] = 1 + offset
    indices[][i+1] = 3 + offset
    indices[][i+2] = 0 + offset
 
    indices[][i+3] = 2 + offset
    indices[][i+4] = 3 + offset
    indices[][i+5] = 1 + offset
    offset += 4
  
  glCreateBuffers(1, result.ibo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, result.ibo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, total_indices * sizeof(uint32), indices[][0].addr, GL_STATIC_DRAW)

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@2d
#---------------------------------------------------------------------------------------------------------------------------------------------------------------


proc draw*(self: Sprite, pos: Vec, size: Vec, rotate: float) =
  self.shader.use()
 
  var model = matrix()
  let sizex = self.w.float32/app.meta.ppu * size.x
  let sizey = self.h.float32/app.meta.ppu * size.y

  model.scale(sizex,sizey,1)
  model.translate(vec(-sizex*0.5, -sizey*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x/app.meta.ppu,pos.y/app.meta.ppu,0,1)) 

  self.shader.setMat("m_model",model)

  glBindTexture(GL_TEXTURE_2D, self.texId)
  glBindVertexArray(self.quad.vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))

  stats.sprites += 1
  stats.drawcalls += 1

proc render_begin*() = 
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
  glClearDepth(1.0f)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  #for shader in shaders:
  # shader.setSampler("u_textures",32,textures[0].addr)

proc render_update*(amount: uint32)=
  spritebatch.vertex_id = amount*4

proc render_end*() = 
  spritebatch.end()
  window.swapBuffers()
  glFlush()

proc flush(self: var SpriteBatch) =

  #for i in 0..texture_next_id:
  #  glBindTextureUnit(i.GLuint,i.GLuint)

  #glBindTextureUnit(0,0)
  #glBindTextureUnit(1,1)
  #glBindTextureUnit(2,2)
  #glBindTextureUnit(3,3)

  stats.sprites   += (self.vertex_id.int / 4).int
  glBindBuffer(GL_ARRAY_BUFFER, self.mesh.vbo)
  glBufferSubData(GL_ARRAY_BUFFER,stats.drawcalls*VERTICES_PER_BATCH*sizeof(Vertex),VERTICES_PER_BATCH*sizeof(Vertex),self.mesh.verts[0].addr)
  glBindVertexArray(self.mesh.vao)
  glDrawElements(GL_TRIANGLES, stats.sprites.GLint*6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))
  stats.drawcalls += 1
  

  self.vertex_id = 0

proc start(self: var SpriteBatch)   = discard
proc `end`  (self: var SpriteBatch) = 
  if self.vertex_id == 0: return
  self.flush()


proc draw_quad*(x,y,z: float, w,h: float = 1, tex: GLfloat = 0) =
  let sizex = 0.004f * app.meta.ppu * w
  let sizey = 0.004f * app.meta.ppu * h

  let vertex_id = spritebatch.vertex_id
  
  if vertex_id >= VERTICES_PER_BATCH:
    spritebatch.flush()
  
  let mesh = spritebatch.mesh.addr
  
  let v  = mesh.verts[0+vertex_id].addr
  let v2 = mesh.verts[3+vertex_id].addr
  let v3 = mesh.verts[2+vertex_id].addr
  let v4 = mesh.verts[1+vertex_id].addr
  
  let xx = x / app.meta.ppu
  let yy = y / app.meta.ppu
  
  v.position.x = xx
  v.position.y = yy
  v.position.z = z
  v.color      = col(1,1,1,1)
  v.texcoords  = (0f,0f)
  v.texid = tex

  v2.position.x = xx + sizex
  v2.position.y = yy
  v2.position.z = z
  v2.color      = col(1,1,1,1)
  v2.texcoords  = (1f,0f)
  v2.texid = tex

  v3.position.x = xx + sizex
  v3.position.y = yy + sizey
  v3.position.z = z
  v3.color      = col(1,1,1,1)
  v3.texcoords  = (1f,1f)
  v3.texid = tex
  
  v4.position.x = xx
  v4.position.y = yy + sizey
  v4.position.z = z
  v4.color      = col(1,1,1,1)
  v4.texcoords  = (0f,1f)
  v4.texid = tex
  
  spritebatch.vertex_id += 4

proc draw_quadd*(x,y: float, size: float = 1) =
  let scale = 0.004f * app.meta.ppu * size

  let vertex_id = spritebatch.vertex_id
  
  if vertex_id >= VERTICES_PER_BATCH:
    spritebatch.flush()
  
  let mesh = spritebatch.mesh.addr
  
  let v  = mesh.verts[0+vertex_id].addr
  let v2 = mesh.verts[3+vertex_id].addr
  let v3 = mesh.verts[2+vertex_id].addr
  let v4 = mesh.verts[1+vertex_id].addr

  v.position.x = x
  v.position.y = y
  v.color.x = 1
  v.color.y = 1
  v.color.z = 1
  v.color.w = 1
  #v.color      = col(1,1,1,1)

  v2.position.x = x + scale
  v2.position.y = y
  v2.color.x = 1
  v2.color.y = 1
  v2.color.z = 1
  v2.color.w = 1
  #v2.color      = col(1,1,1,1)

  v3.position.x = x + scale
  v3.position.y = y + scale
  v3.color.x = 1
  v3.color.y = 1
  v3.color.z = 1
  v3.color.w = 1
  #v3.color      = col(1,1,1,1)
  
  v4.position.x = x
  v4.position.y = y + scale
  v4.color.x = 1
  v4.color.y = 1
  v4.color.z = 1
  v4.color.w = 1
  #v4.color      = col(1,1,1,1)
  
  spritebatch.vertex_id += 4

proc get_texture_white(texture: ptr uint32) {.inline.} =
  glCreateTextures(GL_TEXTURE_2D, 1, texture)
  glBindTexture(GL_TEXTURE_2D, texture[])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE.Glint)
  var color = 0xffffffff
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.Glint,1,1,0,GL_RGBA, GL_UNSIGNED_BYTE, color.addr)
  texture_next_id += 1

proc get_sprite_batch(): SpriteBatch = 
  const total_quads   = 1_000_000
  result = SpriteBatch()
  result.mesh = get_mesh_quads(total_quads)

proc render_init*() = 
  spritebatch = get_sprite_batch()
  
  
  #  shader.use()
  #  shader.setSampler("u_textures",32,textures[0].unsafeAddr)
  
proc render_init_finish*() =
  get_texture_white(texturewhite.addr)
  textures[0] = texturewhite.Glint
  for i in 1..textures.high:
    textures[i] = i.GLint

  for shader in shaders:
    shader.use()
    shader.setSamplers("u_textures",32,textures[0].addr)