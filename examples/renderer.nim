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

var image  : TImage
var image2 : TImage

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
  result.shader = shader
  
  var vbo : uint32
  var ebo : uint32
  
  # var verts = @[
  #      # pos      # tex
  #      0.0f, 1.0f, 0.0f, 1.0f,
  #      1.0f, 0.0f, 1.0f, 0.0f,
  #      0.0f, 0.0f, 0.0f, 0.0f, 
   
  #      0.0f, 1.0f, 0.0f, 1.0f,
  #      1.0f, 1.0f, 1.0f, 1.0f,
  #      1.0f, 0.0f, 1.0f, 0.0f
  # ]

  # var verts = @[
      
  #     -1.0,-1, 0.0, # top    right
  #     1, -1,  0.0, # bottom right
  #     1,  1,  0.0, # bottom left
  #     -1,  1,  0.0  # top    left
  #   ]

  # result.shader = shader
  # glCreateVertexArrays(1, result.vao.addr)
  # glBindVertexArray(result.vao)

  # glCreateBuffers(1, vbo.addr)
  # glBindBuffer(GL_ARRAY_BUFFER,vbo)
  # glBufferData(GL_ARRAY_BUFFER, verts.size, verts[0].addr, GL_STATIC_DRAW);

  # glEnableVertexArrayAttrib(vbo, 0)
  # glVertexAttribPointer(0.GLuint, 4.GLint, 0x1406.GLenum, false, (cfloat.sizeof*3).GLsizei, cast[ptr Glvoid](0))
  
  # var indices = @[
  #   0, 1, 2, # 1st triangle
  #   2, 3, 0  # 2nd triangle
  # ]

  # glCreateBuffers(1, ebo.addr)
  # glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,ebo)
  # glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW)

  # must be float
  # origin: top-left
  var origin = 2
  var verts = @[
    0f,0f,
    1f,0f,
    1f,1f,
    0f,1f
    # 0.0f+origins[origin][0], 0.0f+origins[origin][1],
    # 1.0f+origins[origin][1], 0.0f+origins[origin][1],
    # 1.0f+origins[origin][1], 1.0f+origins[origin][1],
    # 0.0f+origins[origin][1], 1.0f+origins[origin][1]
  ]
  verts = @[
    0f,1f,
    1f,1f,
    1f,0f,
    0f,0f
  ]
  verts = @[
      0f,0f,
      0f,-1f,
      1f,-1f,
      1f, 0f
    ]
  verts = @[
      -1f,0f, 0,1,0,1,
      -1f,-1f, 0,1,0,1,
      0f,-1f, 0,1,0,1,
      0f,0f, 0,0,1,1
    ]
  # must be u32
  var indices = @[
    0'u32, 1'u32, 2'u32, 2'u32, 3'u32, 0'u32
  ]
  glGenBuffers(1, vbo.addr)
  glGenBuffers(1, ebo.addr)
  glGenVertexArrays(1,result.vao.addr)
  
  glBindVertexArray(result.vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, verts.size, verts[0].addr, GL_STATIC_DRAW);
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);

  glVertexAttribPointer(0.GLuint, 2.GLint, 0x1406.GLenum, false, (cfloat.sizeof*6).GLsizei, nil)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(1.GLuint, 4.GLint, 0x1406.GLenum, false, (cfloat.sizeof*6).GLsizei, cast[ptr Glvoid](8))
  glEnableVertexAttribArray(1)

#var initialized = false
var vao : uint32
var vbo : uint32
var ebo : uint32

let GL_FLOAT = 0x1406.GLenum
let GL_FALSE = false


# template A_GL_FLOAT =
#   0x1406.GLenum
var initialized = false
var shader : ShaderIndex



proc initialize*(arg: ShaderIndex) =
  if initialized: return
  initialized = true
  shader = arg

 

  image  = loadImage("awesomeface.png")
  image2 = loadImage("tex_hero2_idle_04.png")
  
  image.generate(GL_RGBA)
  image2.generate(GL_RGBA)
  
  shader.use()
  echo image.id, "--", image2.id
  var samplers = [0'u32,1'u32]
  shader.setSampler("u_textures",2,samplers[0].addr)


  var verts = @[
    0.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 0.0f, 1f,
    1.0f,0.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 0.0f, 1f,
    1.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 1.0f, 1.0f, 1f,
    0.0f,1.0f,0.0f, 0.15f, 0.5f, 0.95f, 1.0f, 0.0f, 1.0f, 1f,

    2.0f,0.0f,0.0f, 0.65f, 0.25f, 0.95f, 1.0f, 0.0f, 0.0f, 1f,
    3.0f,0.0f,0.0f, 0.65f, 0.25f, 0.95f, 1.0f, 1.0f, 0.0f, 1f,
    3.0f,1.0f,0.0f, 0.65f, 0.25f, 0.95f, 1.0f, 1.0f, 1.0f, 1f,
    2.0f,1.0f,0.0f, 0.65f, 0.25f, 0.95f, 1.0f, 0.0f, 1.0f, 1f
  ]
  
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  glGenBuffers(1, vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, verts.size, verts[0].addr, GL_STATIC_DRAW)

  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,(cfloat.sizeof*10).GLsizei,cast[ptr Glvoid](0))
  glEnableVertexAttribArray(0)

  glVertexAttribPointer(1,4,GL_FLOAT,GL_FALSE,(cfloat.sizeof*10).GLsizei,cast[ptr Glvoid](cfloat.sizeof*3))
  glEnableVertexAttribArray(1)
  
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,(cfloat.sizeof*10).GLsizei,cast[ptr Glvoid](cfloat.sizeof*7))
  glEnableVertexAttribArray(2)
  
  glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,(cfloat.sizeof*10).GLsizei,cast[ptr Glvoid](cfloat.sizeof*9))
  glEnableVertexAttribArray(3)

  var indices = @[
    0'u32, 1'u32, 2'u32, 2'u32, 3'u32, 0'u32,
    4'u32, 5'u32, 6'u32, 6'u32, 7'u32, 4'u32
  ]

  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);
  #glBindBuffer(1,vao.addr)

proc drawTest*() =

  shader.use()
  #activeTexture(GL_TEXTURE0)
  #bindTexture(GL_TEXTURE_2D,image.id)
  #  activeTexture(GL_TEXTURE0)
  # bindTexture(GL_TEXTURE_2D,texture1)
  # activeTexture(GL_TEXTURE1)
  # bindTexture(GL_TEXTURE_2D, texture2)
  glBIndTextureUnit(0, image.id)
  glBIndTextureUnit(1, image2.id)

  glBindVertexArray(vao)
  
  var model = matrix()
  model.scale(1,1,1)
  model.rotate(0.radians, vec_forward)
  model.translate(vec(0,0,0,1)) 
  
  


  shader.setMatrix("mx_model",model)
  glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, nil)

  # model = matrix()
  # model.scale(1,1,1)
  # model.rotate(0.radians, vec_forward)
  # model.translate(vec(2,0,0,1)) 

  # shader.setMatrix("mx_model",model)
  # glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)


proc drawTest*(shader: ShaderIndex) =
  
  if not initialized:
    initialized = true
    glGenVertexArrays(1,vao.addr)
    glBindVertexArray(vao)

    glGenBuffers(1, vbo.addr)
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, Vertex.sizeof*1000, nil, GL_DYNAMIC_DRAW)

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof.GLsizei, cast[ptr Glvoid](offsetOf(Vertex, position)))
    glEnableVertexAttribArray(0)
    
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, Vertex.sizeof.GLsizei, cast[ptr Glvoid](offsetOf(Vertex, color)))
    glEnableVertexAttribArray(1)

    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, Vertex.sizeof.GLsizei, cast[ptr Glvoid](offsetOf(Vertex, texCoords)))
    glEnableVertexAttribArray(2)

    glVertexAttribPointer(3, 1, GL_FLOAT, GL_FALSE, Vertex.sizeof.GLsizei, cast[ptr Glvoid](offsetOf(Vertex, texID)))
    glEnableVertexAttribArray(3)
    
    var indices = @[
      0'u32, 1'u32, 2'u32, 2'u32, 3'u32, 0'u32
    ]

    glGenBuffers(1, ebo.addr)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW);
  
  
  var q0 = createQuad(-1.5f,-0.5f,0.0f)
   
  var verts = @[
      -1f,0f,0, 0,1,0,1, 0,0, 0,
      -1f,-1f,0, 0,1,0,1, 0,0, 0,
      0f,-1f,0, 0,1,0,1, 0,0, 0,
      0f,0f,0, 0,0,1,1,0,0, 0,

      -1f,0f,0, 0,1,0,1, 0,0, 0,
      -1f,-1f,0, 0,1,0,1, 0,0, 0,
      0f,-1f,0, 0,1,0,1, 0,0, 0,
      0f,0f,0, 0,0,1,1,0,0, 0
    ]


  glBindBuffer(GL_ARRAY_BUFFER,vbo)
  glBufferSubData(GL_ARRAY_BUFFER, 0, verts.sizeof, verts[0].addr)

  shader.use()
  var model = matrix()
  
  model.scale(1,1,1)
  #model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(0.radians, vec_forward)
  model.translate(vec(0,0,0,1)) 

  shader.setMatrix("mx_model",model)

  glBindVertexArray(vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
  #glMapBuffer(GL_ARRAY_BUFFER, vbo)
  #glBindVertexArray(self.vao)
  #glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)


proc draw*(self: Quad, pos: Vec, size: Vec, rotate: float, col: Vec) =
  self.shader.use()
  var model = matrix()
  
  model.scale(size.x,size.y,1)
  #model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x,pos.y,0,1)) 

  self.shader.setMatrix("mx_model",model)
  self.shader.setVec3("sprite_color", col)

  glBindVertexArray(self.vao)
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)

proc drawNotOpt*(self: Quad, pos: Vec, size: Vec, rotate: float, col: Vec) =
  self.shader.use()
  var model = matrix()
  
  model.scale(size.x,size.y,1)
  model.translate(vec(-size.x*0.5, -size.y*0.5 , 0, 1))
  model.rotate(rotate.radians, vec_forward)
  model.translate(vec(pos.x,pos.y,0,1)) 

  self.shader.setMatrix("mx_model",model)
  self.shader.setVec3("sprite_color", col)

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
  #glBindTexture(GL_TEXTURE_2D, 0)
  #glGenerateMipmap(GL_TEXTURE_2D)

proc bindTex*(self: var Timage) =
  glBindTexture(GL_TEXTURE_2D, self.id)