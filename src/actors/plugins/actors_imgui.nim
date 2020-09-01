{.used.}
import dear_imgui/imgui
import dear_imgui/imgui/[impl_opengl, impl_glfw]

export imgui, impl_opengl, impl_glfw

#from ../actors_engine import window

proc releaseImpl*()=
  impl_opengl.igOpenGL3Shutdown()
  impl_glfw.igGlfwShutdown()

proc renderBegin*()=
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

proc renderEnd*()=
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())

proc bootstrap*(obj: ptr object)=
  let context {.used.} = igCreateContext()
  assert igGlfwInitForOpenGL(obj, true)
  assert igOpenGL3Init()
  igStyleColorsCherry()