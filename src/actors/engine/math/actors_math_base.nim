{.compile: "actors_math_base.c".}
import actors_math_h

proc invSqrt*(number: cfloat): cfloat {.importc.}

proc radians*(angle: float32): float32 {.inline.} =
  angle * rad_per_deg

proc rads*(angle: float32): rad {.inline.} =
  (angle * rad_per_deg).rad

proc max*(val1: float32, val2: float32): float32 =
  if val1 < val2:
    val2
  else:
    val1