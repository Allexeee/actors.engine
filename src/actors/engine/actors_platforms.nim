{.used.}
when defined(renderer_opengl):
  import platforms/renderer/actors_opengl as renderer
  
when defined(target_windows):
  when defined(renderer_opengl):
    import platforms/target/actors_target_windows_opengl as target

export renderer
export target