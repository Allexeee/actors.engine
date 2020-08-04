import actors
import actors/vendor/actors_gl

type SpriteRenderer* = ref object of RootObj
  shader* : ShaderIndex
  vao   * : uint32


proc init*(self: SpriteRenderer, shader: ShaderIndex) =
  self.shader = shader
  var vbo : uint32 = 0
  var vertices = @[
      -0.5f, -0.5f, 0.0f, # left  
      0.5f, -0.5f, 0.0f,  # right 
      0.0f,  0.5f, 0.0f   # top   
  ]
  glGenVertexArrays(1,self.vao.addr)
  glGenBuffers(1,vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, vertices.size, vertices[0].addr, GL_STATIC_DRAW)

  glVertexAttribPointer(0.GLuint, 3.GLint, 0x1406.GLenum, false, (cfloat.sizeof*3).GLsizei, cast[ptr Glvoid](0))
  glEnableVertexAttribArray(0)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)
  # var vertices = @[
  #      0.0f, 1.0f, 0.0f, 1.0f,
  #      1.0f, 0.0f, 1.0f, 0.0f,
  #      0.0f, 0.0f, 0.0f, 0.0f, 

  #      0.0f, 1.0f, 0.0f, 1.0f,
  #      1.0f, 1.0f, 1.0f, 1.0f,
  #      1.0f, 0.0f, 1.0f, 0.0f
  # ]
  # glGenVertexArrays(1,self.vao.addr)
  # glGenBuffers(1,vbo.addr)

  # glBindBuffer(GL_ARRAY_BUFFER, vbo)
  # glBufferData(GL_ARRAY_BUFFER, vertices.size, vertices[0].addr, GL_STATIC_DRAW)

  # glBindVertexArray(self.vao)
  # glEnableVertexAttribArray(0)
  # glVertexAttribPointer(0.GLuint, 4.GLint, 0x1406.GLenum, false, (cfloat.sizeof*4).GLsizei, cast[ptr Glvoid](0))
  # glBindBuffer(GL_ARRAY_BUFFER, 0);
  # glBindVertexArray(0);
  
proc generate*(image: ptr TImage): Texture2D =
  var tex = Texture2D()
  glGenTextures(1,tex.id.addr)
  tex.width = (uint32)image.width
  tex.height = (uint32)image.height
  glBindTexture(GL_TEXTURE_2D, tex.id)
  #glTexImage2D(GL_TEXTURE_2D, 0.Glint, GL_RGB.Glint, image.width, image.height, 0.Glint, GL_RGBA, GL_UNSIGNED_BYTE, image.data[0].addr)
  
  glTexImage2D(GL_TEXTURE_2D, 0.Glint, GL_RGB.Glint, image.width, image.height, 0.Glint, GL_RGBA, GL_UNSIGNED_BYTE, image.data[0].addr)
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER.ord);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER.ord);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.ord);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.ord);

  # unbind texture
  glBindTexture(GL_TEXTURE_2D, 0);
  tex


proc draw*(self: SpriteRenderer, texture: Texture2D, pos: Vec, size: Vec, rotate: float, color: Vec) =
  self.shader.use()
  var model = matrix()#; model.identity
  model.scale(size)
  #model.rotate(angle.radians,1,0.3,0.5)
  model.translate(pos)
  #model.scale()
    #  model.rotate(angle,1,0.3,0.5)
  #model.translate(pos)
  # model.translate(pos)
  # model.translate(vec(0.5f * size.x, 0.5f * size.y, 0.0f))
  # model.rotate(rotate.radians, vec_zero)
  # model.translate(vec(-0.5f * size.x, -0.5f * size.y, 0.0f))
  # model.scale(size)

  self.shader.setMatrix("mx_model", model)
  self.shader.setVec("sprite_color", color)
  
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture.id)
  glBindVertexArray(self.vao);
  glDrawArrays(GL_TRIANGLES, 0, 3);
  glBindVertexArray(0);
  
  #texture.Bind();
  
    # // prepare transformations
    # this->shader.Use();
    # glm::mat4 model = glm::mat4(1.0f);
    # model = glm::translate(model, glm::vec3(position, 0.0f));  // first translate (transformations are: scale happens first, then rotation, and then final translation happens; reversed order)

    # model = glm::translate(model, glm::vec3(0.5f * size.x, 0.5f * size.y, 0.0f)); // move origin of rotation to center of quad
    # model = glm::rotate(model, glm::radians(rotate), glm::vec3(0.0f, 0.0f, 1.0f)); // then rotate
    # model = glm::translate(model, glm::vec3(-0.5f * size.x, -0.5f * size.y, 0.0f)); // move origin back

    # model = glm::scale(model, glm::vec3(size, 1.0f)); // last scale

    # this->shader.SetMatrix4("model", model);

    # // render textured quad
    # this->shader.SetVector3f("spriteColor", color);

    # glActiveTexture(GL_TEXTURE0);
    # texture.Bind();

    # glBindVertexArray(this->quadVAO);
    # glDrawArrays(GL_TRIANGLES, 0, 6);
    # glBindVertexArray(0);