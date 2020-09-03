{.used.}
import ../../../actors_h
import ../../../plugins/actors_gl
import ../../../plugins/actors_glfw
import ../../../actors_tools

type Window* = GLFWWindow
var window* : GLFWWindow
var monitor : GLFWMonitor

proc bootstrap*(app: App) = 
  proc getOpenglVersion() =
    var glGetString = cast[proc (name: GLenum): ptr GLubyte {.stdcall.}](glGetProc("glGetString"))
    if glGetString == nil: return
    var glVersion = cast[cstring](glGetString(GL_VERSION))
    logInfo &"OpenGL {glVersion}"
  
  assert glfwInit()==1
 
  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 5)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

 # glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  #glfwWindowHint(GLFWResizable, GLFW_FALSE)

  monitor = glfwGetPrimaryMonitor()

  let screen = app.meta.screen_size
  let name = app.meta.name
  if app.meta.fullscreen:
    window = glfwCreateWindow((cint)screen.width, (cint)screen.height, name, monitor, nil)
    
  else:
    window = glfwCreateWindow((cint)screen.width, (cint)screen.height, name, nil, nil)
  
  

  #window.setW
  #glfwSetWindowAspectRatio(window, 16, 9)
  #glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
  if window == nil:
    quit(-1)

  window.setInputMode(GLFWCursorSpecial,GLFW_CURSOR_DISABLED)
  window.makeContextCurrent()
  
  assert glInit()

  getOpenglVersion()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc getFullscreen*(app:App, arg:bool) =
  let screen = app.meta.screen_size
  if arg:
    window.setWindowMonitor(monitor,0,0,(cint)screen.width, (cint)screen.height, 0)
  else:
    window.setWindowMonitor(nil,0,0,(cint)screen.width, (cint)screen.height, 0)
# proc appGetFullScreen*(arg:bool)=discard


proc quit*() = window.setWindowShouldClose(1)

proc shouldQuit*():bool {.inline.} = (bool)window.windowShouldClose

proc vsync*(app: App, arg:int32) =
  if arg != app.meta.vsync:
    app.meta.vsync = arg
  glfwSwapInterval(arg);
  window.makeContextCurrent()

proc releaseImpl*() =
  window.destroyWindow()
  glfwTerminate()

proc renderBegin*() {.inline.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f)

proc renderEnd*() {.inline.} =
  window.swapBuffers()
  glFlush()

##=====================================================
##@input
##=====================================================
proc pollEvents*() {.inline.} =
  glfwPollEvents()

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