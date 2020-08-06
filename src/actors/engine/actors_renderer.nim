{.used.}
{.experimental: "codeReordering".}


import actors_types
import actors_math
import ../actors_utils
import ../vendor/actors_stb_image
import ../vendor/actors_gl

when defined(renderer_opengl):
  import platforms/renderer/actors_opengl
  export actors_opengl

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
  addSprite(addTexture(filename,MODE_RGBA, MODE_NEAREST, MODE_REPEAT),shader)


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

#