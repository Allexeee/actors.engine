{.used.}
when defined(renderer_opengl):
  import platform/renderer/actors_opengl as renderer
  
when defined(target_windows):
  when defined(renderer_opengl):
    import platform/target/actors_win_opengl as target

export renderer
export target
