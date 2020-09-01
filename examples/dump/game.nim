{.used.}
{.experimental: "codeReordering".}
import actors/vendor/actors_gl
import actors/vendor/actors_imgui
# import actors/vendor/
import actors
export actors

let app* = getApp()

app.settings.fps = 60
app.settings.name = "Game"

app.settings.display_size = (1920, 1080) 

app.settings.path_assets = "examples/assets/"
app.settings.path_shaders = "examples/assets/shaders/"

log "start"

# ImGui.testing()
# IMGUI.testing()

# proc testing(arg: int) =
#     discard

# testing(10)



var
    vertices = @[
        #positions       #coords
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    ]
 
    cube_positions = @[
    vec( 0.0f,  0.0f,  0.0f), 
    vec( 2.0f,  5.0f, -15.0f), 
    vec(-1.5f, -2.2f, -2.5f),  
    vec(-3.8f, -2.0f, -12.3f),  
    vec( 2.4f, -0.4f, -3.5f),  
    vec(-1.7f,  3.0f, -7.5f),  
    vec( 1.3f, -2.0f, -2.5f),  
    vec( 1.5f,  2.0f, -2.5f), 
    vec( 1.5f,  0.2f, -1.5f), 
    vec(-1.3f,  1.0f, -1.5f)    
    ]
   

var vao : uint32 = 0
var vbo : uint32 = 0
var ebo : uint32 = 0
var texture: uint32 = 0
var texture2: uint32 = 0

var shaderDefault : ShaderIndex
var image  = loadImage("wall.jpg")
var image2 = loadImage("awesomeface.png")
 

var mxproj = matrix()
var mxview = matrix()
var cam_pos = vec(0,0,0)
var time = 0.0

# layer engine
# layer game



app.start:
  shaderDefault = shader("sprite")
  shaderDefault.use()
  shaderDefault.setVec("mainColor", vec(1,1,1,1))

  glGenVertexArrays(1,vao.addr)
  glGenBuffers(1,vbo.addr)
  glGenBuffers(1,ebo.addr)
  glBindVertexArray(vao)

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  #glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices[0].addr, GL_STATIC_DRAW) 

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, vertices.size, vertices[0].addr, GL_STATIC_DRAW)
  #var vv : GLenum
 #glVertexAttribPointer*: proc (index: GLuint, size: GLint, `type`: GLenum, normalized: GLboolean, stride: GLsizei, pointer: pointer) {.cdecl, gcsafe.}
  glVertexAttribPointer(0.GLuint, 3.GLint, 0x1406.GLenum, false, (cfloat.sizeof*5).GLsizei, cast[ptr Glvoid](0))
  glEnableVertexAttribArray(0)
  # color attribute
  # glVertexAttribPointer(1'u32, 3, EGL_FLOAT, false, cfloat.sizeof*8, cast[ptr Glvoid](cfloat.sizeof*3))
  # glEnableVertexAttribArray(1);
  # coord attribute
  glVertexAttribPointer(1'u32, 2, 0x1406.GLenum, false, cfloat.sizeof*5, cast[ptr Glvoid](cfloat.sizeof*3))
  glEnableVertexAttribArray(1);
  
  glGenTextures(1,texture.addr)
  glBindTexture(GL_TEXTURE_2D, texture)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.Glint)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.Glint)

  glTexImage2D(GL_TEXTURE_2D, 0.Glint, GL_RGB.Glint, image.width, image.height, 0.Glint, GL_RGB, GL_UNSIGNED_BYTE, image.data[0].addr);
  shaderDefault.setInt("texture",  0)
  glGenTextures(1,texture2.addr)
  glBindTexture(GL_TEXTURE_2D, texture2)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.Glint)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.Glint)

  glTexImage2D(GL_TEXTURE_2D, 0.Glint, GL_RGB.Glint, image2.width, image2.height, 0.Glint, GL_RGBA, GL_UNSIGNED_BYTE, image2.data[0].addr);
  
  shaderDefault.setInt("texture2", 1)


var test: int = 0
var size: float = 2
var aspect_ratio =1920/1080f  
var mx_ortho = matrix(); mx_ortho.ortho(-size * aspect_ratio, size * aspect_ratio, -size, size ,0.01, 1000)
var mx_persp = matrix(); mx_persp.setPerspective(radians 50, aspect_ratio, 0.1, 1000)

var ecam = newCamera()
ecam.ccamera.shaders = newSeq[ShaderIndex]()
ecam.ccamera.shaders.add(shaderDefault)
ecam.ctransform.model = matrix()
ecam.ccamera.projection = mx_persp

app.run:   
  var v2 = vec(0,0)
  var v3 = vec(0,0,0)
  var v4 = vec(0,0,0,0)

  
  var col = rgb(129,100,100,255)

  # var v1 : uint32 = 0
  # v1.setBool("tst",false)
 

  time += dt


  glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
  glEnable(GL_DEPTH_TEST)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture)
  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, texture2)
  

  if app.input.press mb_left:
      mx_proj = mx_ortho
      test = 0
  if app.input.press mb_right:
      mx_proj = mx_persp
      test = 1

  var transform = ecam.cTransform

  if test == 1:
    if app.input.down w:
        transform.pos.z += 0.2
    if app.input.down s:
        transform.pos.z -= 0.2
  else: 
    if app.input.down w:
        size += 0.2
    if app.input.down s:
        size -= 0.2
    mx_ortho.ortho(-size * aspect_ratio, size * aspect_ratio, -size, size ,0.01, 1000)
    mx_proj = mx_ortho
   
  
  if app.input.down a:
      transform.pos.x += 0.2
  if app.input.down d:
      transform.pos.x -= 0.2

  #transform.model.translate(transform.pos)

  var radius = 10.0f
  var camX   = sin(time) * radius;
  var camZ   = cos(time) * radius;
  var view = lookAt(vec(camX, 0.0f, camZ), vec_zero, vec_up) #this works
  
  
  glBindVertexArray(vao)


  for i in 0..9:    
      var angle =  rads(20.0 * i.float32)
      var model = matrix()
      model.scale()
      model.rotate(angle,1,0.3,0.5)
      model.translate(cube_positions[i])
      shaderDefault.setMatrix("mx_model", model)
      glDrawArrays(GL_TRIANGLES, 0, 36)
  


#     for(unsigned int i = 0; i < 10; i++)
# {
#     glm::mat4 model = glm::mat4(1.0f);
#     model = glm::translate(model, cubePositions[i]);
#     float angle = 20.0f * i; 
#     model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
#     ourShader.setMat4("model", model);

#     glDrawArrays(GL_TRIANGLES, 0, 36);
# }

  #glDrawArrays(GL_TRIANGLES, 0, 36)
  #glDrawElements(GL_TRIANGLES, indices.len.cint, GL_UNSIGNED_INT, nil)