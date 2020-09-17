{.used.}
import nimgl/imgui
import nimgl/imgui/impl_opengl
import nimgl/imgui/impl_glfw

export imgui, impl_opengl, impl_glfw


proc releaseImpl*()=
  impl_opengl.igOpenGL3Shutdown()
  impl_glfw.igGlfwShutdown()

proc igHandleCursor*(mode: int) =
  if mode == 0x00034001:
    igSetMouseCursor(ImGuiMouseCursor.Arrow)
  else:
    igSetMouseCursor(ImGuiMouseCursor.None)

proc renderBegin*()=
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

proc renderEnd*()=
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())

proc initImpl*(obj: ptr object)=
  let context {.used.} = igCreateContext()
  discard igGlfwInitForOpenGL(obj, true)
  igStyleColorsCherry()