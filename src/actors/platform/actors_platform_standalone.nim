{.experimental: "codeReordering".}
import nimgl/[glfw]
import ../actors_utils

when defined(opengl):
  import ../graphics/actors_renderer_opengl as renderer

type Window* = GLFWWindow

type
  AppBase* = ref object of RootObj
    window*: Window

var 
  app: AppBase

proc start*(this: AppBase, screensize: tuple[width: int, height: int], name: string) {.inline.} =
  app = this 
  assert glfwInit()
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  app.window =  glfwCreateWindow((cint)screensize.width, (cint)screensize.height, name, nil, nil)
  renderer.start(app.window)



proc shouldQuit*():bool {.inline.} = app.window.windowShouldClose

proc release*()= app.window.setWindowShouldClose(true)

proc updateImpl*() {.inline.}=
  glfwPollEvents()
  app.window.swapBuffers()

proc dispose*() =
  app.window.destroyWindow()
  app.window = nil
  glfwTerminate()

proc used*() = discard

#@input
proc pressKeyImpl*(keycode: cint): bool {.inline.} =
  let state = app.window.getkey(keycode)
  return state == GLFWPress 

proc pressMouseImpl*(keycode: cint): bool {.inline.} =
  let state = app.window.getMouseButton(keycode)
  return state == GLFWPress 
 
proc getMousePositionImpl*(): tuple[x: cfloat,y: cfloat] {.inline.} =
  var x,y : cdouble
  app.window.getCursorPos(addr x,addr y)
  return (x.cfloat,y.cfloat)
