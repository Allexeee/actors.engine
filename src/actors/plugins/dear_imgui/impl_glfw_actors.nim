{.used.}
import imgui
import impl_opengl
import impl_glfw
import ../actors_glfw
#include impl_opeg

export imgui
export impl_opengl
export impl_glfw

var context : ptr ImGuiContext


proc bootstrap*(window: GLFWWindow) =
  #igGlfwInit
  #assert igGlfwInitForOpenGL(window, false)
  context = igCreateContext()

  assert igGlfwInitForOpenGL(window, true)
  #assert igOpenGL3Init()
 
  igStyleColorsCherry()
  #assert igGlfwInitForOpenGL(window, true)
  #let io = igGetIO()
  #io.fonts.addFontDefault() #onts.AddFontDefault()
  #assert igOpenGL3Init()

proc render_begin*() =
  igGlfwNewFrame()
  igOpenGL3NewFrame()
  igNewFrame()

proc flush*() =
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())
  #()
proc poo*() =
  igOpenGL3RenderDrawData(igGetDrawData())
proc kill*()= 
  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()
