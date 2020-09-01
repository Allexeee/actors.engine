## Created by Pixeye | dev@pixeye.com
##
## Opengl implementation.   
## Submodules:   
## * ```shaders```




{.used.}

include actors_renderer_h

proc addTexture*(path: string, mode_rgb: ARenum, mode_filter: ARenum, mode_wrap: ARenum): TextureIndex =
  var w,h,bits : cint
  var textureID : GLuint
  stbi_set_flip_vertically_on_load(true.ord)
  var data = stbi_load(app.meta.assets_path & path, w, h, bits, 0)
  echo w, "_", h
  glCreateTextures(GL_TEXTURE_2D, 1, textureID.addr)
  #echo textureID
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode_wrap.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode_wrap.Glint)
  glTexImage2D(GL_TEXTURE_2D, 0.Glint, mode_rgb.Glint, w, h, 0.Glint, mode_rgb.Glenum, GL_UNSIGNED_BYTE, data)
  stbi_image_free(data)
  textureID.TextureIndex

template `$`*(this: ShaderIndex): uint32 =
  this.uint32

##=====================================================
##@shaders
##=====================================================

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

proc shader*(app: App, shader_path: string): ShaderIndex =    
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
    result = id.ShaderIndex

proc use*(this: ShaderIndex) {.inline.} =
  glUseProgram(this.GLuint) 

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


{.used.}
{.experimental: "codeReordering".}


let GL_FLOAT = 0x1406.GLenum
let GL_FALSE = false

var tempQuad : array[4,Vertex]
var drawcalls* = 0
var drawcallsLast* = 0

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

proc quad(x,y: cfloat, color: Vec, texID: cfloat): Quad {.discardable.} =
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
  
  result.verts = tempQuad

proc updatePos(self: var Quad, x,y: cfloat, sx,sy: cfloat) {.inline.} =
  self.verts[0].position = (x,y,0f)  
  self.verts[1].position = (x+sx,y,0f)
  self.verts[2].position = (x+sx,y+sy,0f)
  self.verts[3].position = (x,y+sy,0f)
  copyMem(verts[nextQuadID].addr,self.verts[0].addr,4*Vertex.sizeof)


proc addSprite*(texture: TextureIndex, shader: ShaderIndex) : Sprite =
  result = Sprite()
  result.texID = texture.uint32
  result.shader = shader
  result.quad = quad(0.0f,0.0f,vec(1,1,1,1),texture.cfloat)
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
    0'u32, 1'u32, 2'u32, 2'u32, 3'u32, 0'u32
  ]
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);

  #glBindBuffer(GL_ARRAY_BUFFER, 0)
  #glBindVertexArray(0)

 
proc addSprite*(filename: string, shader: ShaderIndex) : Sprite =
  addSprite(addTexture(filename,MODE_RGBA, MODE_NEAREST, MODE_REPEAT), shader)


var vboBatch : uint32
var vaoBatch : uint32
var eboBatch : uint32

const maxQuadCount = 110001
const maxVertexCount = maxQuadCount * 4;
const maxIndexCount = maxQuadCount * 6;

var shaderBatch: ShaderIndex

proc prepareBatch*(shader: ShaderIndex) =
  shader.use()
  shaderBatch = shader
  var samplers = [0'u32,1'u32]
  shader.setSampler("u_textures",2,samplers[0].addr)

  glGenVertexArrays(1, vaoBatch.addr)
  glBindVertexArray(vaoBatch)

  glGenBuffers(1, vboBatch.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
  glBufferData(GL_ARRAY_BUFFER, Vertex.sizeof*maxVertexCount, nil, GL_DYNAMIC_DRAW)
 
  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, position)))
  glEnableVertexAttribArray(0)

  glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, color)))
  glEnableVertexAttribArray(1)
  
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
  glEnableVertexAttribArray(2)
  
  glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,Vertex.sizeof.GLsizei,cast[ptr Glvoid](offsetOf(Vertex, texID)))
  glEnableVertexAttribArray(3)


  var indices = newSeq[uint32](maxIndexCount)
  var offset = 0'u32
  for i in countup(0,maxIndexCount-1,6):
    indices[i+0] = 0 + offset
    indices[i+1] = 1 + offset
    indices[i+2] = 2 + offset

    indices[i+3] = 2 + offset
    indices[i+4] = 3 + offset
    indices[i+5] = 0 + offset

    offset += 4

  glGenBuffers(1, eboBatch.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eboBatch)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);

  

proc draw*(self: Sprite, pos: Vec, size: Vec, rotate: float) =
  self.shader.use()
  var model = matrix()
  
  model.scale(size.x,size.y,1)
  model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x,pos.y,0,1)) 

  self.shader.setMatrix("mx_model",model)
  
  glBindVertexArray(self.quad.vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))


var batch* = newSeq[Sprite](maxQuadCount)
#var batchExtended* = newSeq[ptr Vertex](maxQuadCount)
var nextBatchID* : int = 0
var nextQuadID* : int = 0
var indCount* : int = 0



proc drawBatched*(self: Sprite, pos: Vec2, size: Vec2) =
  #var q = self.quad
  self.quad.updatePos(pos.x,pos.y,size.x,size.y)
  #copyMem(verts[nextQuadID].addr,self.quad.verts[0].addr,4*Vertex.sizeof)
  nextQuadID += 4
  indCount+=6

  #batchExtended[nextBatchID] = self.quad[0].addr
  #batch[nextBatchID].quad.quadUpdatePos(pos.x,pos.y,size)
  #nextBatchID += 1
 
var verts : array[maxQuadCount*4,Vertex]

proc flush*() =
  drawcalls += 1
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
  glBufferSubData(GL_ARRAY_BUFFER, 0, verts.size, verts[0].addr) 
  
  glBindVertexArray(vaoBatch)
  
  #var model = matrix()
  #model.translate(vec(0,0,0,1)) 

  #  shaderBatch.setMatrix("mx_model",model)
  glDrawElements(GL_TRIANGLES, indCount.GlSizei, GL_UNSIGNED_INT, nil)
  indCount = 0
  nextQuadID = 0
  drawcallsLast = drawcalls
  drawcalls -= 1


proc flusher*() =
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
  glBufferSubData(GL_ARRAY_BUFFER, 0, verts.size, verts[0].addr) 
  
  glBindVertexArray(vaoBatch)
  
  var model = matrix()
  model.translate(vec(0,0,0,1)) 

  shaderBatch.setMatrix("mx_model",model)
  glDrawElements(GL_TRIANGLES, indCount.GlSizei, GL_UNSIGNED_INT, nil)

template getTime*(): float64 =
  glfwGetTime()