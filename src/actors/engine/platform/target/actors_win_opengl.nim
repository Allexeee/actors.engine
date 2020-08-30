{.used.}
import ../../../actors_h
import ../../../plugins/actors_gl
import ../../../plugins/actors_glfw
import ../../../actors_tools

type Window* = GLFWWindow
var window* : GLFWWindow

proc getOpenglVersion() =
  var glGetString = cast[proc (name: GLenum): ptr GLubyte {.stdcall.}](glGetProc("glGetString"))
  if glGetString == nil: return
  var glVersion = cast[cstring](glGetString(GL_VERSION))
  logInfo &"OpenGL {glVersion}"

# var glGetString = cast[proc (name: GLenum): ptr GLubyte {.stdcall.}](glGetProc("glGetString"))
#   if glGetString == nil: return
#   var glVersion = cast[cstring](glGetString(GL_VERSION))
#   log info, &"OpenGL {glVersion}"

proc bootstrap*(app: App): GLFWWindow {.inline.}= 
  assert glfwInit()
  
  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
 # glfwWindowHint(GLFWDoubleBuffer, 0)
  let screen = app.meta.screen_size
  let name = app.meta.name
  window = glfwCreateWindow((cint)screen.width, (cint)screen.height, name, nil, nil)
  
  if window == nil:
    quit(-1)
  
  window.makeContextCurrent()
  
  assert glInit()
  #assert gladLoadGL(glfwGetProcAddress)

  getOpenglVersion()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  window

proc kill*() =
  window.destroyWindow()
  window = nil
  glfwTerminate()

proc render_begin*() {.inline.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f)

proc render_end*() {.inline.} =
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
  if arg != app.meta.vsync:
    app.meta.vsync = arg
  glfwSwapInterval(arg);
  window.makeContextCurrent()

proc current*(app: AppTime): float =
  glfwGetTime()