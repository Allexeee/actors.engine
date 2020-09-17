{.used.}

import 
    plugins/px_gl,
    plugins/px_glfw,
    plugins/px_stb_image,
    plugins/px_imgui
export
    px_gl,
    px_glfw,
    px_stb_image,
    px_imgui

proc pluginsInit*(window: ptr object) =
  px_imgui.initImpl(window)

proc release*() =
  px_imgui.releaseImpl()
  #imgui.release()
#when defined(renderer_opengl):
