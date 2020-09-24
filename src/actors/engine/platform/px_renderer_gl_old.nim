
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@2d
#---------------------------------------------------------------------------------------------------------------------------------------------------------------

proc draw*(self: Sprite, x,y,z: float, w,h: float, rotate: float) {.inline.} = draw(self,vec(x,y,z),vec(w,h), rotate)
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


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#@shapes
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
var lineVAO : GLuint
proc initLine() =
  var segments = @[
    0.0f,0.0f,10.0f,
    0.2f,0.2f,10.0f]
  var lineVBO : GLuint
  glGenVertexArrays(1, lineVAO.addr)
  glGenBuffers(1, lineVBO.addr)
  glBindVertexArray(lineVAO)
  glBindBuffer(GL_ARRAY_BUFFER, lineVBO)
  glBufferData(GL_ARRAY_BUFFER, sizeof(uint32)*6, segments[0].addr, GL_STATIC_DRAW);
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), cast[ptr Glvoid](0))
  var width = @[1f,100f]
#GLfloat lineWidthRange[2] = {0.0f, 0.0f};
  glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, width[0].addr);

#   GLfloat lineSeg[] =
# {
#     0.0f, 0.0f, 0.0f, // first vertex
#     2.0f, 0.0f, 2.0f // second vertex
# };

# GLuint lineVAO, lineVBO;
# glGenVertexArrays(1, &lineVAO);
# glGenBuffers(1, &lineVBO);
# glBindVertexArray(lineVAO);
# glBindBuffer(GL_ARRAY_BUFFER, lineVBO);
# glBufferData(GL_ARRAY_BUFFER, sizeof(lineSeg), &lineSeg, GL_STATIC_DRAW);
# glEnableVertexAttribArray(0);
# glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (void*)0);

proc drawLine*(x,y: float, shader: ShaderIndex) =
  shader.use()
  

  var model = matrix()
  # let sizex = self.w.float32/app.meta.ppu * size.x
  # let sizey = self.h.float32/app.meta.ppu * size.y

  #model.scale(1,1,1)
 # model.translate(vec(-1*0.5, -1*0.5 , 0, 1))
 # model.rotate(rotate.radians, vec_forward)
  model.translate(vec(x,y)) 
  shader.setMat("m_model",model)
  # self.shader.setMatrix("mx_model",model)
  # shader.setMat4("view", view);
  # model = glm::mat4(1.0f);
  # model = glm::translate(model, glm::vec3(0.0f, 0.5f, 0.0f));
  # shader.setMat4("model", model);
  #glEnable(GL_LINE_SMOOTH);
  #glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glEnable(GL_LINE_SMOOTH)
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glBindVertexArray(lineVAO)
  glLineWidth(12f)
  glDrawArrays(GL_LINES, 0, 2)
  glLineWidth(1f)
  # var model = matrix()
  # let sizex = self.w.float32/app.meta.ppu * size.x
  # let sizey = self.h.float32/app.meta.ppu * size.y

  # model.scale(sizex,sizey,1)
  # model.translate(vec(-sizex*0.5, -sizey*0.5 , 0, 1))
  # model.rotate(rotate.radians, vec_forward)
  # model.translate(vec(pos.x/app.meta.ppu,pos.y/app.meta.ppu,0,1)) 

  # self.shader.setMatrix("mx_model",model)

  # glBindTexture(GL_TEXTURE_2D, self.texId)
  # glBindVertexArray(self.quad.vao)
  # glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))
  discard



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

  initLine()
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

const am = 25_000

proc updateTiles*() = 
  vertId = 1_000_000*4

proc updatePos*(x,y,z: cfloat) =
  const size = 0.008f * 24

  if vertId >= 4*am:
    batchEnd()
    flush()
    batchBegin()
  #var offset = stats.drawcalls
  var v  = vertBatch[0+vertId].addr
  var v2 = vertBatch[3+vertId].addr
  var v3 = vertBatch[2+vertId].addr
  var v4 = vertBatch[1+vertId].addr
  v.position   = vec3(x,y,z)
  v2.position  = vec3(x+size,y,z)
  v3.position  = vec3(x+size,y+size,z)
  v4.position  = vec3(x,y+size,z)
  vertId += 4


proc updateNose*() =

  if vertId >= 4*am:
    batchEnd()
    flush()
    batchBegin()

  vertId += 4
  #vertId = 4*1_000_000
 # batchEnd()
 # flush()
 # batchBegin()

proc updatePose*(x,y: cfloat) =
  const size = 0.004f * 32f

  if vertId >= 4*100000:
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

proc updateAll*(x,y: cfloat, scale: cfloat = 1, ccos: cfloat, csin: cfloat) =
  const ddsize = 0.004f
  const ddsize2 = -0.002f

  if vertId >= 4*am:
    batchEnd()
    flush()
    batchBegin()

  let dx = ddsize2 * scale
  let dy = ddsize2 * scale
  let w = ddsize * scale
  let h = w
 # let ccos = cos(ang)
 # let csin = sin(ang)

  let v  = vertBatch[0+vertId].addr
  let v2 = vertBatch[3+vertId].addr
  let v3 = vertBatch[2+vertId].addr
  let v4 = vertBatch[1+vertId].addr
  
  v.position.x  = x + dx * ccos - dy * csin
  v.position.y  = y + dx * csin + dy * ccos;
  #v.position.z = 0

  v2.position.x = x + (dx+w) * ccos - dy * csin
  v2.position.y = y + (dx+w) * csin + dy * ccos;
  #v2.position.z = 0

  v3.position.x = x + (dx+w) * ccos - (dy+h) * csin
  v3.position.y = y + (dx+w) * csin + (dy+h) * ccos;
  #v3.position.z = 0
    
  v4.position.x = x + dx * ccos - (dy+h) * csin
  v4.position.y = y + dx * csin + (dy+h) * ccos;
 # v4.position.z = 0
  
  vertId += 4

# var zsin = sin(0f)
# var zcos = cos(0f)

# var ztable : array[360,float]
# var ctable : array[360,float]
# for i in 0..360:
#   ztable[i] = sin(i.float)#sin(360f/i.float*0.02f)
#   ctable[i] = cos(i.float)#cos(360f/i.float*0.02f)


# func sinn*(x:float): float = 
#   const B = 4 / PI
#   const C = -4 / (PI*PI)
#   -(B*x+C*x*(if x < 0: -x else: x))
proc updateAll*(x,y: cfloat, scale: cfloat = 1, ang: float ) =
  var ang_temp {.global.} : float
  var ccos {.global.} : float
  var csin {.global.} : float
  #var xx {.global.} : float
  #var yy {.global.} : float

  const ddsize = 0.004f
  const ddsize2 = -0.002f

  if vertId >= 4*am:
    batchEnd()
    flush()
    batchBegin()

  let dx = ddsize2 * scale
  let dy = ddsize2 * scale
  let w  = ddsize  * scale
  let h  = w

  if ang != ang_temp:
    ang_temp = ang
    ccos = cos(ang)
    csin = sin(ang)
 

  let v  = vertBatch[0+vertId].addr
  let v2 = vertBatch[3+vertId].addr
  let v3 = vertBatch[2+vertId].addr
  let v4 = vertBatch[1+vertId].addr
  
  v.position.x  = x + dx * ccos - dy * csin
  v.position.y  = y + dx * csin + dy * ccos;
  #v.position.z = 0

  v2.position.x = x + (dx+w) * ccos - dy * csin
  v2.position.y = y + (dx+w) * csin + dy * ccos;
  #v2.position.z = 0

  v3.position.x = x + (dx+w) * ccos - (dy+h) * csin
  v3.position.y = y + (dx+w) * csin + (dy+h) * ccos;
  #v3.position.z = 0
    
  v4.position.x = x + dx * ccos - (dy+h) * csin
  v4.position.y = y + dx * csin + (dy+h) * ccos;
 # v4.position.z = 0
  
  vertId += 4
proc makeQuad*(x,y: cfloat, color: Vec, texID: cfloat) {.discardable.} =
  const size = 0.008f

  if vertId >= 4*am:
    batchEnd()
    flush()
    batchBegin()
 
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

#var offset
var offset : int
proc batchBegin*()=
  #if vertId >= max_amount*4:
  vertId = 0
  #echo stats.drawcalls
 # offset = stats.drawcalls* 4*100000
  #vertId = 0 #stats.drawcalls*4*100000#stats.drawcalls*10000
  #offset = stats.drawcalls

proc batchEnd*()=
  
  #echo vertId
 # let amount = vertId.GLint
  glBindBuffer(GL_ARRAY_BUFFER, vboBatch)
 # echo amount
  glBufferSubData(GL_ARRAY_BUFFER,stats.drawcalls*4*am*sizeof(Vertex),4*am*sizeof(Vertex),vertBatch[0].addr)
  

proc flush*() =
  let amount = (vertId / 4).GLint
  #if amount == 0:
  #echo amount
  stats.drawcalls+=1
  stats.sprites += amount
  vertId = 0

proc renderBegin*() =
  discard
proc renderEnd*() =
  shaders[0].use()
  var model = matrix()
  shaders[0].setMat("m_model",model)
  glBindTexture(GL_TEXTURE_2D, whiteTexture)
  glBindVertexArray(vaoBatch)
  glDrawElements(GL_TRIANGLES, stats.sprites.GLint*6, GL_UNSIGNED_INT, cast[ptr Glvoid](0))