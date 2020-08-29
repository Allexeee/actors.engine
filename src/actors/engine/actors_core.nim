import ../actors_h
import actors_platform as platform

proc quit*(self: App) =
  platform.target.release()

proc count_metrics_begin*() =
  stats.frames += 1
  stats.updates += 1
  discard

proc count_metrics_end*() =
  discard