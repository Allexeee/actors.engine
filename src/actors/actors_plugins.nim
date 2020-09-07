{.used.}

import 
    plugins/actors_gl,
    plugins/actors_glfw
export
    actors_gl,
    actors_glfw

import
  plugins/actors_stb_image,
  plugins/actors_imgui as imgui_impl

export
  actors_stb_image,
  imgui_impl


proc init*(window: ptr object) =
  imgui_impl.initImpl(window)

proc release*() =
  imgui_impl.releaseImpl()
  #imgui.release()
#when defined(renderer_opengl):
