{.used.}
{.experimental: "codeReordering".}

import ../../px_plugins

type ARenum* = GLenum # ActorsRender

const
  MODE_LINEAR*          : ARenum = GL_LINEAR
  MODE_NEAREST*         : ARenum = GL_NEAREST
  MODE_REPEAT*          : ARenum = GL_REPEAT
  MODE_CLAMP_TO_BORDER* : ARenum = GL_CLAMP_TO_BORDER
  MODE_CLAMP_TO_EDGE*   : ARenum = GL_CLAMP_TO_EDGE
  MODE_REPEAT_MIRRORED* : ARenum = GL_MIRRORED_REPEAT
  MODE_RGB*             : ARenum = GL_RGB8
  MODE_RGBA*            : ARenum = GL_RGBA

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

include px_renderer_h

##=====================================================
##@shaders
##=====================================================

var shaders* = newSeq[ShaderIndex]()

template `$`*(this: ShaderIndex): uint32 =
  this.uint32

template checkErrorShaderCompile(obj: uint32, errType: ShaderCompileType): untyped =
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
    checkErrorShaderCompile(vertex, VERTEX_INFO)
    ##fragment
    fragment = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragment,1'i32,frag_code.addr, nil)
    glCompileShader(fragment)
    checkErrorShaderCompile(fragment, FRAGMENT_INFO)
    ##geom
    if geom_code!=default(cstring):
       geom = glCreateShader(GL_GEOMETRY_SHADER)
       glShaderSource(geom, 1'i32,geom_code.addr, nil)
       glCompileShader(geom)
       checkErrorShaderCompile(geom, GEOMETRY_INFO)
    ##program
    id = glCreateProgram()
    glAttachShader(id,vertex)
    glAttachShader(id,fragment)
    if geom_code!=default(cstring):
        glAttachShader(id,geom)
    glLinkProgram(id)
    checkErrorShaderCompile(id, PROGRAM_INFO)
    glDeleteShader(vertex)
    glDeleteShader(fragment)
    shaders.add(id.ShaderIndex)
    result = id.ShaderIndex

proc use*(self: ShaderIndex) =
  var inUse {.global.} : ShaderIndex
  if self.int == inuse.int: return
  inuse = self
  glUseProgram(self.GLuint) 

proc setSampler*(this: ShaderIndex, name: cstring, count: GLsizei, arg: ptr uint32) {.inline.} =
   glUniform1iv(glGetUniformLocation(this.GLuint,name),count, cast[ptr Glint](arg))

proc setBool*(this: ShaderIndex, name: cstring, arg: bool) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setInt*(this: ShaderIndex, name: cstring, arg: int) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setFloat*(this: ShaderIndex, name: cstring, arg: float32) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1f(glGetUniformLocation(this.GLuint,name),arg)

proc setVec*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setVec3*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform3f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z)

proc setColor*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setMatrix*(this: ShaderIndex, name: cstring, arg: var Matrix) {.inline.} =
  ## dont forget to set use before changing shader
  glUniformMatrix4fv(glGetUniformLocation(this.GLuint,name), 1, false, arg.e11.addr)

##=====================================================
##@renderer
##=====================================================

let GL_FLOAT = 0x1406.GLenum
let GL_FALSE = false

var tempQuad : array[4,Vertex]
var drawcalls* = 0
var drawcallsLast* = 0


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

proc getTexture(path: string, mode_rgb: ARenum, mode_filter: ARenum, mode_wrap: ARenum): tuple[id: TextureIndex, w: int, h: int] =
  var w,h,bits : cint
  var textureID : GLuint
  stbi_set_flip_vertically_on_load(true.ord)
  var data = stbi_load(app.meta.assets_path & path, w, h, bits, 0)
  glCreateTextures(GL_TEXTURE_2D, 1, textureID.addr)
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode_wrap.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode_wrap.Glint)
  glTexImage2D(GL_TEXTURE_2D, 0, mode_rgb.Glint, w, h, 0, mode_rgb.Glenum, GL_UNSIGNED_BYTE, data)
  stbi_image_free(data)
  (textureID.TextureIndex,w.int,h.int)


proc getSprite(db: DataBase, texture: tuple[id: TextureIndex, w: int, h: int], shader: ShaderIndex) : Sprite =
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
  #0'u32, 1'u32, 3'u32, 0'u32, 3'u32, 2'u32
  var indices = @[
     1'u32, 3'u32, 0'u32, 2'u32, 3'u32,1'u32
    #2'u32, 3'u32, 1'u32, 1'u32, 3'u32,0'u32
  ]
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);
  glBindTextureUnit(1, result.texID)

proc getSprite*(db: DataBase, filename: string, shader: ShaderIndex) : Sprite =
  db.getSprite(getTexture(filename,MODE_RGBA, MODE_NEAREST, MODE_REPEAT), shader)

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
  
  glBindTexture(GL_TEXTURE_2D, 2)
  glBindVertexArray(self.quad.vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))

  stats.sprites += 1
  stats.drawcalls += 1

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

  # glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))
  # glEnableVertexAttribArray(0)

  # glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  # glEnableVertexAttribArray(1)
  
  # glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
  # glEnableVertexAttribArray(2)
  
  # glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))
  # glEnableVertexAttribArray(3)
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
  vertId += 4
  #var v = vertBatch[0+vertId].addr
  #echo vertId
 # vertBatch[0+vertId].position  = vec3(x,y)
  #vertBatch[0+vertId].color     = color
 #v.texCoords = vec2(0.0f, 0.0f)
  #vertBatch[0+vertId].texID     = texID
  
#  var v2 = vertBatch[3+vertId].addr
 # vertBatch[3+vertId].position  = vec3(x+size, y)
 # vertBatch[3+vertId].color     = color
  #v.texCoords = vec2(1.0, 0.0)
 # vertBatch[3+vertId].texID     = texID

  #var v3 = vertBatch[2+vertId].addr
 # vertBatch[2+vertId].position  = vec3(x+size, y+size)
 # vertBatch[2+vertId].color     = color
 #v.texCoords = vec2(1.0, 1.0)
 # vertBatch[2+vertId].texID     = texID

  #var v4 = vertBatch[1+vertId].addr
 # vertBatch[1+vertId].addr.position = vec3(x, y+size)
 # vertBatch[1+vertId].addr.color     = color
 # v.texCoords = vec2(0.0, 1.0)
 # vertBatch[1+vertId].addr.texID     = texID
  # var v = vertices[0+vertId].addr
  # v.position  = vec3(x,y,0f)
  
  # v = vertices[1+vertId].addr
  # v.position  = vec3(x+size, y, 0.0)

  # v = vertices[2+vertId].addr
  # v.position  = vec3(x+size, y+size, 0.0)

  # v = vertices[3+vertId].addr
  # v.position  = vec3(x, y+size, 0.0)


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