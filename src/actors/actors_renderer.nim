when defined(renderer_opengl):
  import platform/renderer/actors_opengl
  export actors_opengl

proc used*() = discard #ugly hack
