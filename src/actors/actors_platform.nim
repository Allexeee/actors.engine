when defined(target_windows):
  import platform/target/actors_windows
  export actors_windows

proc used*() = discard #ugly hack