import ../../../vendor/actors_gl
import ../../../vendor/actors_glfw
import ../../../actors_utils
 
var window* : GLFWWindow

proc getOpenglVersion() =
  var glGetString = cast[proc (name: GLenum): ptr GLubyte {.cdecl, gcsafe.}](glfwGetProcAddress("glGetString"))
  if glGetString == nil: return
  var glVersion = cast[cstring](glGetString(GL_VERSION))
  log info, &"OpenGL {glVersion}"

proc start*(screensize: tuple[width: int, height: int], name: string) {.inline.} = 
  assert glfwInit()
  
  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 5)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWDoubleBuffer, 0)
  
  window =  glfwCreateWindow((cint)screensize.width, (cint)screensize.height, name, nil, nil)
  
  if window == nil:
    quit(-1)
  
  window.makeContextCurrent()
  assert gladLoadGL(glfwGetProcAddress)
  getOpenglVersion()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc render_end*(vsync: int32) {.inline.} =
  
  window.swapBuffers()
  glFlush()

proc setVSync*(arg: int32) =
  glfwSwapInterval(arg);
  window.makeContextCurrent()
