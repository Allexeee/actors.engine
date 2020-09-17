{.used.}

import 
    plugins/actors_gl,
    plugins/actors_glfw
export
    actors_gl,
    actors_glfw

import
  plugins/px_stb_image,
  plugins/actors_imgui as imgui_impl

export
  px_stb_image,
  imgui_impl


proc pluginsInit*(window: ptr object) =
  imgui_impl.initImpl(window)

proc release*() =
  imgui_impl.releaseImpl()
  #imgui.release()
#when defined(renderer_opengl):
