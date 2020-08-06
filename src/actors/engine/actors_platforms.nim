{.used.}
when defined(renderer_opengl):
  import platforms/renderer/actors_opengl as renderer
  
when defined(target_windows):
  import platforms/target/actors_target_windows as target

export renderer
export target