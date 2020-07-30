when defined(renderer_opengl):
  include actors_target_windows_opengl

 
proc shouldQuit*():bool {.inline.} = window.windowShouldClose

proc release*()= window.setWindowShouldClose(true)

proc updateImpl*() {.inline.}=
  glfwPollEvents()
  window.swapBuffers()

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