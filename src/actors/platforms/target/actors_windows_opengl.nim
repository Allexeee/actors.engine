import ../../vendor/glad/gl
import ../../vendor/glfw/actors_glfw
#import nimgl/[glfw, opengl]
import ../../actors_utils


var window : GLFWWindow


proc start*(screensize: tuple[width: int, height: int], name: string) {.inline.} = 
  assert glfwInit()
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  
  window =  glfwCreateWindow((cint)screensize.width, (cint)screensize.height, name, nil, nil)
  
  window.makeContextCurrent()
  assert gladLoadGL(glfwGetProcAddress)
  #assert glInit()
  #log(info, "Opengl v" & $glVersionMajor & "." & $glVersionMinor)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
