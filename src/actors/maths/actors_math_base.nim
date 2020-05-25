{.compile: "actors_math_base.c".}

import math
export math


const rad_per_deg*  = PI / 180.0 
const epsilon_sqrt* = 1e-15F
const epsilon*      = 0.00001 #for floating-point inaccuracies.


type rad* = distinct float32

proc invSqrt*(number: cfloat): cfloat {.importc.}

proc radians*(angle: float32): float32 {.inline.} =
  angle * rad_per_deg

proc rads*(angle: float32): rad {.inline.} =
  (angle * rad_per_deg).rad
