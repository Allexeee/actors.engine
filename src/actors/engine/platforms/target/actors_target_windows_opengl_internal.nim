import actors_target_windows_opengl

import ../../../actors_header
import ../../../plugins/actors_gl
import ../../../plugins/actors_glfw
import ../../../actors_tools

var window* : Window

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
  
  window = glfwCreateWindow((cint)screensize.width, (cint)screensize.height, name, nil, nil)
  
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


proc shouldQuit*():bool {.inline.} = window.windowShouldClose

proc release*()= window.setWindowShouldClose(true)

proc pollEvents*() {.inline.} =
  glfwPollEvents()

proc dispose*() =
  window.destroyWindow()
  window = nil
  glfwTerminate()

#@input
proc pressKeyImpl*(keycode: cint): bool {.inline.} =
  let state = window.getkey(keycode)
  return state == GLFWPress 

proc pressMouseImpl*(keycode: cint): bool {.inline.} =
  let state = window.getMouseButton(keycode)
  return state == GLFWPress 
 
proc getMousePositionImpl*(): tuple[x: cfloat,y: cfloat] {.inline.} =
  var x,y : cdouble
  window.getCursorPos(addr x,addr y)
  return (x.cfloat,y.cfloat)


proc vsync*(app: App, arg:int32) =
  if arg != app.settings.vsync:
    app.settings.vsync = arg
  glfwSwapInterval(arg);
  window.makeContextCurrent()

proc current*(app: AppTime): float =
  glfwGetTime()