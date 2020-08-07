{.used.}
when defined(target_windows):
  when defined(renderer_opengl):
    import ../platform/target/private/actors_win_opengl as target

export target
