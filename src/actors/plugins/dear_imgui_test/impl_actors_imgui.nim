include imgui
include impl_glfw
include impl_opengl

import ../actors_glfw
# # import imgui
# # import imgui/private/impl_glfw
# # import imgui/private/impl_opengl
# # import ../../actors_glfw

var context : ptr ImGuiContext


proc bootstrap*(w: GLFWWindow) =
  context = igCreateContext()
  
  assert igGlfwInitForOpenGL(w, true)
  assert igOpenGL3Init()
  #igOpenGL3CreateFontsTexture()
  #igOpenGL3CreateDeviceObjects()
  igStyleColorsCherry()
  #var io = igGetIO()
  #ImGuiIO& io = ImGui::GetIO();
#ImFont* pFont = io.Fonts->AddFontFromFileTTF("sansation.ttf", 10.0f);
  #var io = igGetIO()

proc render_begin*() =
   igGlfwNewFrame()
   igOpenGL3NewFrame()
   igNewFrame()

proc flush*() =
  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())

proc kill*()= 
  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()