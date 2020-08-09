import ../../actors_h
import actors_platform as platform

proc count_metrics_begin*() =
  stats.frames += 1
  stats.updates += 1
  discard

proc count_metrics_end*() =
  discard