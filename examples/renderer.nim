{.used.}
{.experimental: "codeReordering".}

import actors
import actors/vendor/actors_gl

type Triangle* = ref object
  vao* : uint32
  shader*: ShaderIndex

type Quad* = ref object
  vao* : uint32
  shader*: ShaderIndex


proc initTriangle*(shader: ShaderIndex) : Triangle =
  result = Triangle()
  var vbo : uint32
  var verts = @[
    -0.5f, -0.5f, 0.0f, 
     0.5f, -0.5f, 0.0f, 
     0.0f,  0.5f, 0.0f
  ]
  result.shader = shader
  glGenVertexArrays(1,result.vao.addr)
  glGenBuffers(1, vbo.addr)
  
  glBindVertexArray(result.vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, verts.size, verts[0].addr, GL_STATIC_DRAW);
 
  glVertexAttribPointer(0.GLuint, 3.GLint, 0x1406.GLenum, false, (cfloat.sizeof*3).GLsizei, cast[ptr Glvoid](0))
  glEnableVertexAttribArray(0)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

proc draw*(self: Triangle) =
  self.shader.use()
  glBindVertexArray(self.vao); 
  glDrawArrays(GL_TRIANGLES, 0, 3);


proc initQuad*(shader: ShaderIndex) : Quad =
  result = Quad()
  var vbo : uint32
  var verts = @[
    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f, 

    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, 1.0f, 1.0f, 1.0f,
    1.0f, 0.0f, 1.0f, 0.0f
  ]
  result.shader = shader
  glGenVertexArrays(1,result.vao.addr)
  glGenBuffers(1, vbo.addr)
  
  glBindVertexArray(result.vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, verts.size, verts[0].addr, GL_STATIC_DRAW);
 
  glVertexAttribPointer(0.GLuint, 4.GLint, 0x1406.GLenum, false, (cfloat.sizeof*4).GLsizei, cast[ptr Glvoid](0))
  glEnableVertexAttribArray(0)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

proc draw*(self: Quad, pos: Vec, size: Vec, rotate: float, col: Vec) =
  self.shader.use()
  var model = matrix()
  
  model.scale(size.x,size.y,1)
  model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x,pos.y,0,1)) 

  self.shader.setMatrix("mx_model",model)
  self.shader.setVec3("sprite_color", col)
  
  #glActiveTexture(GL_TEXTURE0)
  #image.bindTex()

  glBindVertexArray(self.vao)
  glDrawArrays(GL_TRIANGLES, 0, 6)

proc draw*(self: Quad, image: var TImage, pos: Vec, size: Vec, rotate: float, col: Vec) =
  self.shader.use()
  var model = matrix()
  
  model.scale(size.x,size.y,1)
  model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x,pos.y,0,1)) 

  self.shader.setMatrix("mx_model",model)
  self.shader.setVec3("sprite_color", col)
  
  glActiveTexture(GL_TEXTURE0)
  image.bindTex()

  glBindVertexArray(self.vao)
  glDrawArrays(GL_TRIANGLES, 0, 6)

proc generate*(self: var TImage, rgb: Glenum) =
  glGenTextures(1, self.id.addr)
  glBindTexture(GL_TEXTURE_2D, self.id);
  glTexImage2D(GL_TEXTURE_2D, 0.Glint, rgb.Glint, self.width, self.height, 0.Glint, rgb, GL_UNSIGNED_BYTE, self.data[0].addr)
  # set Texture wrap and filter modes
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.Glint)
  # unbind texture
  glBindTexture(GL_TEXTURE_2D, 0)
  #glGenerateMipmap(GL_TEXTURE_2D)

proc bindTex*(self: var Timage) =
  glBindTexture(GL_TEXTURE_2D, self.id)