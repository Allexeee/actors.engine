import ../actors_h
import private/actors_platform as platform

proc quit*(self: App) =
  platform.target.release()

# import
#   core/actors_interfaces,
#   core/actors_time

# export
#   actors_interfaces,
#   actors_time