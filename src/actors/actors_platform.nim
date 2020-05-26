when defined(renderer_opengl):
  import platform/renderer/actors_opengl
  export actors_opengl

when defined(target_windows):
  import platform/target/actors_windows
  export actors_windows 


proc used*() = discard #ugly hack