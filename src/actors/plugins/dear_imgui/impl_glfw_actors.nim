include impl_glfw




var context : ptr ImGuiContext


proc ui_bootstrap*(window: GLFWWindow) =
  context = igCreateContext()
  igStyleColorsCherry()
  assert igGlfwInitForOpenGL(window, true)

proc renderer_begin*() =
  igGlfwNewFrame()
  igNewFrame()

proc flush*() =
  igRender()

proc dispose*()= 
  #igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()
  #igOpenGL3RenderDrawData(igGetDrawData())

  #assert igOpenGL3Init()

#context = igCreateContext()
# igStyleColorsCherry()

# proc ui_bootstrap(window: Win) =
#   discard