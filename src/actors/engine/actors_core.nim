import ../actors_h
import private/actors_platform as platform

proc quit*(self: App) =
  platform.target.release()

